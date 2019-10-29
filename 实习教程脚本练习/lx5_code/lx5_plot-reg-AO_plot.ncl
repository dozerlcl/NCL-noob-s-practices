begin
;;data reader
  f = addfile("./practice/lx5_data/temporary_data/confi_rc_slp.nc", "r")
  f_eof = addfile("./practice/lx5_data/temporary_data/eof.nc", "r")
  list_filevars(f)  
  confi_rc_slp = f->confi_rc_slp
  rc_slp       = f->rc_slp
  eof          = f_eof->eof
  ; printVarSummary(confi_rc_slp) 
  sig_pcv = confi_rc_slp@sig_pcv ; sig_pcv 作为属性值保存在变量confi中
;;plot设置
  wks = gsn_open_wks("x11","plot-reg-SLP")
  gsn_define_colormap(wks,"rainbow")  
  ; res设置：显著性的填色图和回归场的等值线分开绘制，先设定两图公用的绘图参数
  res                   = True    
  res@gsnAddCyclic      = True ; ?
  res@gsnDraw           = False         
  res@gsnFrame          = False        
  res@gsnLeftString     = ""
  res@gsnRightString    = ""  

  res@gsnTickMarksOn = False
  ; 关闭经度标签。虽然默认是绘制经度标签，但由于其经度单位前没有“度”符号，即“o”，所以这里关闭了其经度标签。
  ; 若需绘制标准的经度标签，可利用函数gsn_add_text（详见附录A.5节）以及文本函数符号“~”（附录图A.5）进行手动添加。
  
  ; resc设置：用于显著性图
  resc = res                          ;复制给resc,用以绘制回归场的等值线          
    
  res@gsnPolar          = "NH"        ;北半球的极射赤面投影    
  ; print(sig_pcv)
  if(sig_pcv(0).eq.1)then ; 之前的north检验，类型是integer，但是if需要logic，很奇怪，因为示例脚本如此写
    res@gsnCenterString = "EOF1 is significant"
  else
    res@gsnCenterString = "EOF1 is not significant"
  end if
  res@gsnCenterStringFontHeightF = 0.03
  res@gsnCenterStringOrthogonalPosF = 0.0 ;?
  res@mpFillOn        = False       
  res@mpMinLatF       = 10          ; 地图的最南纬度
  res@mpMaxLatF       = 90          ; 最北纬度
  res@mpCenterLonF    = 180         ; 中心经度
  
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = (/-20,20/) ; -20与20均对应着0.05置信度，但前者对应负值异常，后者对应正值异常
  res@cnFillColors          = (/"gray","white","gray"/)
  res@cnFillOn              = True 
  res@lbLabelBarOn          = False   ; 由于绘制的是显著性（只有几个值），一般不需要绘制以下几项           
  res@cnLinesOn             = False   ;  
  res@cnInfoLabelOn         = False   ; 
  res@cnLineLabelsOn        = False   ; 
   
  base = gsn_csm_contour_map_polar(wks, confi_rc_slp, res)

  ;; 回归场等值线的设置
  resc@cnLevelSelectionMode  = "ExplicitLevels"
  resc@cnLevels              =  1.*ispan(-10,10,1)    
  resc@cnFillOn              = False    
  resc@cnInfoLabelOn         = False
  resc@gsnContourZeroLineThicknessF = 0.
  resc@cnLineThicknessF             = 2.
  resc@cnLineLabelsOn               = False
  plot = gsn_csm_contour(wks,rc_slp,resc) 
  plot = ColorNegDashZeroPosContour(plot,"black","black","black")
  
  overlay(base, plot) ; 图层叠加

  ;; 添加格外的等值线
  resc2 = resc
  resc2@cnLevels           := (/-4,2/)  
  resc2@cnLineThicknessF   = 7.  
  resc2@cnMonoLineDashPattern = False
  resc2@cnLineDashPatterns    = (/1,0/) ; 两根线用不同的线型； 也可通过ColorNegDashZeroPosContour实现
  resc2@cnLineDashSegLenF     = 0.25    ; 虚线上每个线段的长度，会自动控制其之间的间隔
  plot2 = gsn_csm_contour(wks,rc_slp,resc2) 
   
  overlay(base,plot2)
  
  draw(base)
  frame(wks)

end