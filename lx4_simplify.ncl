load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
year=ispan(1979,2013,1)  ; 79/80 - 13/14
it_s=197912  ;起始年月
it_e=201411  ;结束年月

refmag = 3   ;参考箭头所表示的风速大小

;;;read data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
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

;;;DJF 平均 & 异常 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  sst_DJF = month_to_season(sst,"JFM");JFM季节平均，实际是12/1/2月三个月平均，因为从1979年12月开始截取
  copy_VarMeta(sst(0,:,:),sst_DJF(0,:,:));将所有属性， 命名尺寸 和 坐标变量 从一个变量复制到另一个
  sst_DJF!0 = "year";创建命名维度year(原本是time)
  sst_DJF&year=year ;将命名维度设置为year
  ;printVarSummary(sst_DJF)
  sst_ano = dim_rmvmean_n_Wrap(sst_DJF,0);计算并减去所有其他维度上给定维度的均值(即求距平)，并保留元数据
   ;之后对剩下四个变量的设置是相似的
    
;;;(3) enso index (5N-5S, 170-120W);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  ;计算en地区的区域平均（设置维度
  ensoi = wgt_areaave_Wrap(sst_DJF(:,{-5:5},{190:240}), 1., 1., 0); 0表示仅用非缺省的数值进行计算 
  ;计算结果标准化
  ensoi = dim_standardize_Wrap(ensoi, 1) ;1 表示标准化时除以的是[N] ; 而0表示除以[N-1]
  
;   ;; 输出至netcdf文件
;   path_out = "ENSO-index.nc"
;   system("rm -f "+ path_out)      ; 若当前路径下有同名文件，则删除
;   ncdf = addfile(path_out,"c")    ; "c" 表示创建 netCDF 文件
;   ncdf->ensoi = ensoi
  
; ;;;(4) composite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  irec_positive = ind(ensoi.gt.0.8)   ;找到ensoi较大的值的位置
  nnumb = dimsizes(irec_positive)     ;其实只有7个时次
  ;printVarSummary(nnumb)
  ;print(nnumb)
  ;print(irec_positive)
  ;对ensoi较高的七个时次的五项指标的异常（就距平ano）进行合成（其实就是求平均)
  sst_comp   = dim_avg_n_Wrap(sst_ano(irec_positive,:,:), 0)

;;; (5) t-test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; sst
  sst_std = dim_variance_n_Wrap(sst_ano(irec_positive,:,:),0)
  sst_std = sqrt(sst_std/nnumb)
  sst_std = where(sst_std.eq.0,sst_std@_FillValue,sst_std)
  t_sst   = sst_comp/sst_std       
  confi_sst = sst_comp
  confi_sst = student_t(t_sst, nnumb-1)    
    
;;; (5) plot
    wks = gsn_open_wks("png", "lx4_simplified")
    gsn_define_colormap(wks, "BlWhRe");设置色板
res = True
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@gsnContourZeroLineThicknessF = 3
    res@lbLabelBarOn = True

    res@mpMinLatF = -90
    res@mpMaxLatF = 90
    res@mpMinLonF = 0
    res@mpMaxLonF = 360
    
    res@cnSmoothOn  = True
    res@cnFillOn = True;画填充图
    res@cnLinesOn = True ;no contour
    res@cnLineLabelsOn = False ;no contour labels
    res@cnSmoothingOn = True
    plot = gsn_csm_contour_map (wks, sst_comp, res)
end
