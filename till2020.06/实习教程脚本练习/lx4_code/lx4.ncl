load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
year=ispan(1979,2013,1)  ; 79/80 - 13/14
it_s=197912  ;起始年月
it_e=201411  ;结束年月

refmag = 3   ;参考箭头所表示的风速大小

;;;read data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
   ;;  sst
   ;从所给路径打开文件对象
  f_sst = addfile("./practice/lx4_data/sst-197901-201501.nc", "r")
  time   = f_sst->time              ; 读取其日期
  YYYYMM = cd_calendar(time, -1); 转换成公历日期
  ;printVarSummary(time)            ; 查看下是如何进行转换的（从一个数转成年月 
  ;printVarSummary(YYYYMM)    
  ; 截取指定时间段   
  rec_s = ind(it_s .eq. YYYYMM)      ;获取开始时间的记录号，对应1979年12月，记录为11
  rec_e = ind(it_e .eq. YYYYMM)      ;获取结束时间的记录号，对应2014年11月，记录为430
  ; print(res_s)
  ; print(res_e)
  sst = f_sst->sst(rec_s:rec_e,:,:)  ;截取从开始到结束这段时间的资料
   ;; h300 
  ;printVarSummary(sst)
   f_h300 = addfile("./practice/lx4_data/h300-197901-201412.nc", "r")
   h300   = short2flt(f_h300->hgt(rec_s:rec_e,0,{-90:90},:))  

   ;; u850 
   f_u850 = addfile("./practice/lx4_data/u850-197901-201412.nc", "r")
   u850   = short2flt(f_u850->uwnd(rec_s:rec_e,0,{-90:90},:))  ; 850 hPa    
   
   ;; v850 
   f_v850 = addfile("./practice/lx4_data/v850-197901-201412.nc", "r")
   v850   = short2flt(f_v850->vwnd(rec_s:rec_e,0,{-90:90},:))  ; 850 hPa

   ;; air2m 
   f_air2m = addfile("./practice/lx4_data/air2m-197901-201412.nc", "r")
   air2m   = short2flt(f_air2m->air(rec_s:rec_e,0,{-90:90},:))  ; T at 2m    

;;;DJF 平均 & 异常 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  sst_DJF = month_to_season(sst,"JFM");JFM(1,2,3月)平均，实际是12/1/2月三个月平均，因为从1979年12月开始截取
  copy_VarMeta(sst(0,:,:),sst_DJF(0,:,:));将所有属性， 命名尺寸 和 坐标变量 从一个变量复制到另一个
  sst_DJF!0 = "year";创建命名维度year(原本是time)
  sst_DJF&year=year ;将命名维度设置为year
  ;printVarSummary(sst_DJF)
  sst_ano = dim_rmvmean_n_Wrap(sst_DJF,0);计算并减去所有其他维度上给定维度的均值(即求距平)，并保留元数据
   ;之后对剩下四个变量的设置是相似的
  ;; h300
  h300_DJF = month_to_season(h300, "JFM") 
  copy_VarMeta(h300(0,:,:),h300_DJF(0,:,:))
  h300_DJF!0 = "year"
  h300_DJF&year=year 

  h300_ano = dim_rmvmean_n_Wrap(h300_DJF,0)

  ;; u850 与h300 同维  
  u850_DJF = month_to_season(u850, "JFM") 
  copy_VarMeta(h300_DJF,u850_DJF)

  u850_ano = dim_rmvmean_n_Wrap(u850_DJF,0)
  
  ;; v850 与h300 同维  
  v850_DJF = month_to_season(v850, "JFM") 
  copy_VarMeta(h300_DJF,v850_DJF)   

  v850_ano = dim_rmvmean_n_Wrap(v850_DJF,0)
    
  ;; air2m
  air2m_DJF = month_to_season(air2m, "JFM") 
  copy_VarMeta(air2m(0,:,:),air2m_DJF(0,:,:))
  air2m_DJF!0   ="year"
  air2m_DJF&year=year   
    
  air2m_ano = dim_rmvmean_n_Wrap(air2m_DJF,0)
    
;;;(3) enso index (5N-5S, 170-120W);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  ;计算en地区的区域平均（设置维度
  ensoi = wgt_areaave_Wrap(sst_DJF(:,{-5:5},{190:240}), 1., 1., 0); 0表示仅用非缺省的数值进行计算 
  ;计算结果标准化
  ensoi = dim_standardize_Wrap(ensoi, 1) ;1 表示标准化时除以的是[N] ; 而0表示除以[N-1]
  
  ;   ;; 输出至netcdf文件
  ;   path_out = "ENSO-index.nc"
  ;   system("rm -f "+ path_out)      ; 若当前路径下有同名文件，则删除
  ;   ncdf = addfile(path_out,"c")    ; "c" 表示创建 netCDF 文件
  ;   ncdf->ensoi = ensoi
  
;;;(4) composite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  irec_positive = ind(ensoi.gt.0.8)   ;找到ensoi较大的值的位置
  nnumb = dimsizes(irec_positive)     ;其实只有7个时次
  ;printVarSummary(nnumb)
  ;print(nnumb)
  ;print(irec_positive)
  ;对ensoi较高的七个时次的五项指标的异常（就距平ano）进行合成（其实就是求平均)
  sst_comp   = dim_avg_n_Wrap(sst_ano(irec_positive,:,:), 0)
  h300_comp  = dim_avg_n_Wrap(h300_ano(irec_positive,:,:),0) 
  u850_comp  = dim_avg_n_Wrap(u850_ano(irec_positive,:,:),0)    
  v850_comp  = dim_avg_n_Wrap(v850_ano(irec_positive,:,:),0) 
  air2m_comp = dim_avg_n_Wrap(air2m_ano(irec_positive,:,:),0)  
  ;printVarSummary(sst_comp)
  ;printVarSummary(sst_ano)

;;;(5) t-test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; sst
  sst_std = dim_variance_n_Wrap(sst_ano(irec_positive,:,:),0)
  sst_std = sqrt(sst_std/nnumb)
  sst_std = where(sst_std.eq.0,sst_std@_FillValue,sst_std) ; where(条件，条件为真的值，条件为假的值)
  t_sst   = sst_comp/sst_std 
  confi_sst = sst_comp ; 与sst_comp相同的meta data
  confi_sst = student_t(t_sst, nnumb-1) ;对t_sst做t检验，自由度为nnumb-1
  ;printVarSummary((confi_sst))
  ;; h300
  h300_std = dim_variance_n_Wrap(h300_ano(irec_positive,:,:),0)
  h300_std = sqrt(h300_std/nnumb)
  t_h300   = h300_comp/h300_std       
  confi_h300 = h300_comp
  confi_h300 = student_t(t_h300, nnumb-1)   

  ;; air2m
  air2m_std = dim_variance_n_Wrap(air2m_ano(irec_positive,:,:),0)
  air2m_std = sqrt(air2m_std/nnumb)
  t_air2m   = air2m_comp/air2m_std       
  confi_air2m = air2m_comp
  confi_air2m = student_t(t_air2m, nnumb-1) 
    
;;;(5) plot
  wks = gsn_open_wks("x11","plot-comp-enso")
  gsn_define_colormap(wks,"rainbow+gray")  ; 调用rainbow+gray色板

;其它色板名称请查阅http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
  base = new(3,"graphic")
  plot = new(3,"graphic")  

;res设置   绘制base中的confi_填色的阴影部分
  res                   = True   ; 调整地图及显著性等值线,
  res@gsnAddCyclic      = True   ; 添加循环点，否则会在0度经线左侧出现一根白条
  res@gsnDraw           = False        
  res@gsnFrame          = False        
  res@gsnLeftString     = ""
  res@gsnRightString    = ""
  ; 拷贝,各个子图具体要素的绘制
  resc = res  ; 画sst_comp,下面的plot(0)
  resv = res  ; 画u850，v850，下面的plot(1)
  rest = res  ; 画air_2m,下面的plot(2)
  
  res@mpFillOn             = False        ; 不填色地图
  res@mpCenterLonF         = 180          ; 地图的中心经度 
  res@mpGeophysicalLineThicknessF = 0.5   ; 地图边界的粗细
  res@pmTickMarkDisplayMode= "Always"     ; 坐标上标签上添加度符号
  res@mpGridAndLimbOn      = True         ; 绘制经纬度线
  res@mpGridLatSpacingF    = 15           ; 经纬度线间隔
  res@mpGridLonSpacingF    = 15           ;
  res@mpGridLineDashPattern= 2            ; 经纬度线线型取为类型为2的虚线。共17种线型供选择。
  res@mpgridlinethicknessF = 0.5          ; 其粗细
              
  res@cnFillOn             = True         ; 填色等值线
  res@cnLinesOn            = True         ; 绘制等值线
  res@cnLineColor          = "white"      ; 颜色
  res@cnLineThicknessF     = 0.3          ; 粗细
  res@cnLineLabelsOn       = False        ; 关闭标签

  
  
  res@cnLevelSelectionMode  = "ExplicitLevels"  
  res@cnLevels              = (/0.01,0.05/)  
  res@cnFillPalette         = "GMT_gray"; 用GMT_gray 进行填色。即调用了第2种色板
  res@cnFillColor           = (/5, 7, -1/); -1 为透明

  res@cnInfoLabelOn         = False       ; 关闭图右下方的等值线信息标签
  res@lbLabelBarOn          = False       ; 关闭labelbar

;resc设置:绘制plot中的_comp红蓝白等值线部分
  resc@cnLevelSelectionMode  = "ExplicitLevels"                ; 指定每根需绘制的等值线
  resc@cnLevels              = (/-0.75,-0.25,0.25,0.75,1.25/)  ;   
  resc@cnFillOn              = False     ; 关闭等值线填色 
  resc@cnLineThicknessF      = 2.        ; 等值线粗细  
  resc@gsnContourZeroLineThicknessF = 0. ; 设置0值线粗细。0则不画
  resc@cnLineLabelsOn        = False     ; 关闭标签
  resc@cnLineDashPattern     = 16        ; 线型为16的虚线
  resc@cnInfoLabelOn         = False      ; 关闭图右下方的等值线信息标签
  resc@cnInfoLabelOrthogonalPosF = 0.05  ; 移动等值线信息标签的位置

;resv设置：绘制u，v风速矢量部分
  resv@vcPositionMode            = "ArrowTail"  ;箭头尾部对应着格点的位置
  resv@vcGlyphStyle              = "Fillarrow"  ;其余三种选项为“LineArrow”、“WindBarb” 、“CurlyVector”
  resv@vcFillArrowEdgeThicknessF = 2         ; 箭头边界粗细
  resv@vcFillArrowEdgeColor      = "white"   ; 及颜色
  resv@vcFillArrowFillColor      = "black"  ; 箭头内部填充颜色
  resv@vcFillArrowWidthF         = 0.1       ; 箭头宽度
  resv@vcFillArrowHeadXF         = 0.6       ; 请参考附录中Fillarrow箭头示意图
  resv@vcFillArrowHeadYF         = 0.2       ;
  resv@vcFillArrowHeadInteriorXF = 0.25      ; 
           
  resv@vcMinDistanceF            = 0.03    ; 箭头之间的最小距离（在单位平方中）
  resv@vcMinMagnitudeF           = 1.0     ; 要绘制箭头所表示的最小数值，即小于该数值则不绘制

  resv@vcFillArrowMinFracWidthF =1.0 
  resv@vcFillArrowHeadMinFracXF =1.0  
  resv@vcFillArrowHeadMinFracYF =1.0 
  
   ;****设定参考箭头****
    resv@vcRefAnnoOn               = True  
    resv@vcRefMagnitudeF           = refmag  ;标准长度箭头所表示的大小
    resv@vcRefLengthF              = 0.045   ;标准长度箭头在单位平方中的大小
    resv@vcRefAnnoBackgroundColor  = "white" ;背景颜色     
    resv@vcRefAnnoPerimOn          = False   ;关闭边框    
                                        
    resv@vcRefAnnoFontHeightF      = 0.015   ;参考箭头标签字体大小      
    
    resv@vcRefAnnoString1On     = False   ;设定参考箭头上、下的字符        
    resv@vcRefAnnoString2On     = True    ; 这里仅设定其下方的字符
    resv@vcRefAnnoString2       = refmag+" m/s"  
           
    resv@vcRefAnnoSide            = "Top" ; 参考箭头放至图形上方
    resv@vcRefAnnoOrthogonalPosF  = -0.12 ; 调整其位置
    resv@vcRefAnnoParallelPosF    = 0.95 

; base(0),plot(0): confi_sst sst_comp
  res@gsnCenterString            = "sst" ;子图的主标题 
  res@gsnCenterStringFontHeightF = 0.03 
  ;标题字体的大小。由于后面没有修改该值，则每幅图的主标题字体均是此大小
  base(0) = gsn_csm_contour_map(wks, confi_sst, res)  ; 只有底图可有地图（map）  
  plot(0) = gsn_csm_contour(wks, sst_comp, resc)      ; 调用的绘图函数不可带“map”
  plot(0) = ColorNegDashZeroPosContour(plot(0),"blue","white","red")
  ;负值用蓝色虚线表示，0线用白色实线，正值红色实线
  overlay(base(0), plot(0))     ; 带地图的图必须放在最下图层

; glres,gres设置：绘制多边形及折线以标明nino 3.4区 添加在base(0)上
  plres                  = True
  plres@gsLineColor      = "black"
  plres@gsLineThicknessF = 1.0
  
  gres                   = True
  gres@gsFillColor       = "yellow"
  gres@gsFillOpacityF    = 0.5
  gres@gsLineColor       = "black"
   
  latx = (/-5,    5,  5, -5, -5/)    ; nino3.4区的坐标位置
  lonx = (/190, 190, 240, 240, 190/)  ;
  dum1 = gsn_add_polyline(wks,base(0),lonx,latx,plres)   
  dum2 = gsn_add_polygon(wks,base(0),lonx,latx,gres)

; base(1),plot(1)+plotv：base(1)绘制confi_h300，plot(1)绘制h300_comp，plotv绘制风向uv
  res@gsnCenterString = "h300&V850"  
  resc@cnLevelSelectionMode  = "AutomaticLevels" 
  resc@cnLevelSpacingF = 15.
  base(1) = gsn_csm_contour_map(wks,confi_h300,res)  
  plot(1) = gsn_csm_contour(wks,h300_comp,resc) ;风速大小的等值线图，下面进行调整
  plot(1) = ColorNegDashZeroPosContour(plot(1),"blue","white","red")
  overlay(base(1),plot(1))
  
  plotv   = gsn_csm_vector(wks,u850_comp,v850_comp,resv) ;风向的绘制
  overlay(base(1),plotv)  ; 也可用gsn_csm_vector_map(wks,h300_comp,u850,v850,res_new)

; base(2),plot(2):base(2)绘制confi_air2m,plot(2)绘制air2m_comp
  res@gsnCenterString       = "air2m"  
  resc@cnLevelSelectionMode = "ManualLevels" 
  resc@cnMaxLevelValF       = 2
  resc@cnMinLevelValF       = -2 
  resc@cnLevelSpacingF      = 0.5    
  base(2) = gsn_csm_contour_map(wks,confi_air2m,res)  
  plot(2) = gsn_csm_contour(wks,air2m_comp,resc) 
  plot(2) = ColorNegDashZeroPosContour(plot(2),"blue","black","red")
  overlay(base(2),plot(2))  

; resP最后出panel图设置
  resP = True                        ; 绘制panel图
  resP@txString       = "El nino"    ; 添加主标题
  resP@txFontHeightF  = 0.03         ; 修改其大小  

 ; resP@gsnPanelFigureStrings= (/"a)","b)","c)"/)  ;各个子图的标号
  resP@gsnPanelFigureStringsFontHeightF = 0.015   ;字体的大小 
  resP@amJust = "TopLeft"                         ;摆放的位置，默认是“BottomRight”
  
  resP@gsnPanelRowSpec = True        ; 指定每行绘制的子图的个数
  gsn_panel(wks,base,(/1,2/),resP)        ; 第1行绘制1幅，第2行绘制2幅，合成在base中（overlay

end
