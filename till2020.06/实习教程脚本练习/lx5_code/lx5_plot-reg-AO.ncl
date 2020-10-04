begin

;;;;read SLP data   
  f     = addfile("./practice/lx5_data/mslp.mon.mean.r2.nc", "r")
  ; list_files() ;列举可用的文件句柄
  ; list_filevars(f)
  ; printFileVarSummary(f, "time") ; time的unit，自1800，hours；注意时间的格式：日期时间坐标
  ; 与标准起点（本数据是1800），固定单位（units： hours） 的序列
  slp = short2flt(f->mslp(::12,{0:90},:))  ;读取每年的1月，北半球数据
  slp_time=f->time(::12) 
  ; print(time)
  ; printVarSummary(slp)
  dims = dimsizes(slp)                    ; 返回各维的大小,time x lat x lon
  year = ispan(1979,1979+dims(0)-1,1)     ; 自己生成年份
  ; ;; 计算权重  
  w  = sqrt(cos(0.01745329*slp&lat) )     ; 权重系数                 
  wp = slp*conform(slp, w, 1)
; ///////////
  ; 用wp_test说明下conform的原理，顺带注意二维数组的输出，打印如何美观
  ; wp_test = conform(slp, w, 1)
  ; printVarSummary(wp_test)             
  ; write_matrix(wp_test(0,:,:), dims(1)+"F6.3", False)
  ; delete(wp_test)
  ; ;conform:此函数将创建一个新变量，该变量具有与x相同的维度和与r相同的类型。r的值将被复制到所有其他维度。
; ////////////
  copy_VarCoords(slp, wp) ; 将slp的named dimension 和coordinate variable拷贝到wp 
  
;;EOF分解
  ; printVarSummary(wp)
  x = wp({lat|20:90},lon|:,time|:)  ; 时间维放最右边,注： |是命名维度的分隔符，表lat的值从20到90
  ; printVarSummary(x)
  neof = 2                             ; 保留前2模态，用于检验第1模态是否显著与其他模态相分离
;eof参数设置
  optEOF_test = True
  optEOF_test@jopt = 0                 ;默认为0，采用协方差矩阵，1采用相关系数矩阵
  eof  = eofunc_Wrap(x, neof, optEOF_test)   ; EOF分解
  ; printVarSummary(eof)                 ; EOFattributes中信息较多，例如奇异值和奇异值解释方差
;; north 检验
  ntim = dims(0)               
  sig_pcv = eofunc_north(eof@pcvar, ntim, False) ; 采用north方法评估奇异值eof中的属性
    
; ;; 计算时间序列eof_ts，并标准化
  eof_ts = eofunc_ts_Wrap(x, eof, False) ; False选项是ts计算的opt逻辑变量
  eof_ts = dim_standardize_n(eof_ts,1,1) ; 对eof_ts的第二个维度做标准化归一
  ; printVarSummary(eof_ts)              ; eof_ts的属性设置与x相同
;; 输出至netcdf文件
  path_out = "./practice/lx5_data/SLP-PC1-jan"+dims(0)+"yr.nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
  ;时间的处理 1：直接用UT形式  2：修改units之后精简些 (拒绝手动ispan)
  ; printVarSummary(eof_ts&time)
  timeset4eof_ts = cd_calendar(eof_ts&time, 4) ; 将 用units+起始坐标定义出的时间转化成cd_calendar的形式
  ; print(timeset4eof_ts) ; timeset4eof_ts 是 1979-2012 YYYY形式的数组
  timeset4eof_ts_changeunit = time_to_newtime(eof_ts&time, "years since 1800-1-1 00:00") ; 改变units
  ; print(timeset4eof_ts_changeunit) ; timeset4eof_ts_changeunit 是179 - 212 @units 如上所述的数组

  eof_ts!1 = "Time"
  eof_ts&Time = timeset4eof_ts_changeunit
  ncdf->AOI = eof_ts(0,:) ;写入变量数值， 并将输出的变量命名为AOI，这里只储存PC1
;; 回归SLP场 PC1
  ;回归场，是一元回归系数场
  ;注意regCoef和regcoef的差别，输入参数是否放在了attributes中
  xx = regCoef(eof_ts(0, :), slp({lat|:}, {lon|:}, {time|:})) ; 数组变形，最左边的维度需要time
  ; printVarSummary(xx)
  ;; t-test
  rc_slp = new(dims(1:2), float) ; new一个lat x lon 的数组再赋变量meta
  copy_VarMeta(slp(0,:,:), rc_slp)
  confi_rc_slp = rc_slp
  ; rc_slp = slp(0,:,:) ; otherwise：创建个新的变量, 利用赋值直接拷贝属性
  rc_slp = xx/100     ; 转变单位为hPa
  ; printVarSummary(rc_slp)
  P = student_t(xx@tval, xx@nptxy-2)
  confi_rc_slp = reshape(P, (/dims(1), dims(2)/) ) ; 或者用onedtond函数
  ; printVarSummary(confi_rc_slp)
     
  ; ; 如下处理的目的是方便绘图（不是必须）
  ; confi_rc_slp = where(confi_rc_slp.eq.0,confi_rc_slp@_FillValue,confi_rc_slp)  
  ; confi_rc_slp = 1/confi_rc_slp
  ; confi_rc_slp = where(rc_slp.lt.0,-1*confi_rc_slp,confi_rc_slp)
  
; ;;;;;;;;;plot;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  ; wks = gsn_open_wks("eps","plot-reg-SLP")
  ; gsn_define_colormap(wks,"rainbow")  
         
  ; res                   = True    
  
  ; res@gsnDraw           = False         
  ; res@gsnFrame          = False        
  ; res@gsnLeftString     = ""
  ; res@gsnRightString    = ""  

  ; res@gsnTickMarksOn = False ; 关闭经度标签。虽然默认是绘制经度标签，但由于其经度单位前没有“度”符号，即“o”，所以这里关闭了其经度标签。若需绘制标准的经度标签，可利用函数gsn_add_text（详见附录A.5节）以及文本函数符号“~”（附录图A.5）进行手动添加。
  
  ; resc = res          ;复制给resc,用以绘制回归场的等值线          
    
  ;         ;北半球的极射赤面投影    
  
  ; res@mpFillOn        = False       
  ;          ; 地图的最南纬度
  ; res@mpMaxLatF       = 90          ; 最北纬度
  ;          ; 中心经度
  
  ; res@cnLevelSelectionMode  = "ExplicitLevels"
  ; res@cnLevels              = (/-20,20/) ; -20与20均对应着0.05置信度，但前者对应负值异常，后者对应正值异常
  ; res@cnFillColors          = (/"gray","white","gray"/)
  ; res@cnFillOn              = True 
  ; res@lbLabelBarOn          = False   ; 由于绘制的是显著性（只有几个值），一般不需要绘制以下几项           
  ; res@cnLinesOn             = False   ;  
  ; res@cnInfoLabelOn         = False   ; 
  ; res@cnLineLabelsOn        = False   ; 
   
 

  ; ;; 回归场等值线的设置
  ; resc@cnLevelSelectionMode  = "ExplicitLevels"
  ; resc@cnLevels              =  1.*ispan(-10,10,1)    
  ; resc@cnFillOn              = False    
  ; resc@cnInfoLabelOn         = False
  ; resc@gsnContourZeroLineThicknessF = 0.
  ; resc@cnLineThicknessF             = 2.
  ; resc@cnLineLabelsOn               = False
  ; plot = gsn_csm_contour(wks,rc_slp,resc) 
  ; plot = ColorNegDashZeroPosContour(plot,"black","black","black")
  
  ;  ; 图层叠加

  ; ;; 添加格外的等值线
  ; resc2 = resc
  ; resc2@cnLevels           := (/-4,2/)  
  ; resc2@cnLineThicknessF   = 7.  
  ; resc2@cnMonoLineDashPattern = False
  ; resc2@cnLineDashPatterns    = (/1,0/) ; 两根线用不同的线型； 也可通过ColorNegDashZeroPosContour实现
  ; resc2@cnLineDashSegLenF     = 0.25    ; 虚线上每个线段的长度，会自动控制其之间的间隔
  ; plot2 = gsn_csm_contour(wks,rc_slp,resc2) 
   
  ; overlay(base,plot2)
  
  ; draw(base)
  ; frame(wks)

end
