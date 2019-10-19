begin
  z = generate_2d_array(15,15,-100.,110.,0,(/40,40/))

  wks = gsn_open_wks("x11","contour_tm_ex")
  gsn_define_colormap(wks,"GrayWhiteGray")
  
  res = True  
  res@gsnDraw   = False 
  res@gsnFrame  = False 

  res@gsnContourZeroLineThicknessF = 0. ;略去0线
  res@cnLevelSelectionMode = "ManualLevels" ;等间隔地指定等值线范围
  res@cnMinLevelValF = -40
  res@cnMaxLevelValF = 40
  res@cnLevelSpacingF = 10 ;等值线间隔
  
  res@cnFillOn             = False
  
  res@cnLinesOn            = True 
  res@cnLineThicknessF     = 0.5
  
  res@lbOrientation = "Vertical" ; 把标题垂直地移动？

  res@tmXBMode = "Explicit" ;指定X轴坐标标签
  res@tmXBValues = ispan(5, 35, 10) ;用数组替代一下(/5,15,25,35/)?
  res@tmXBLabels = (/"Jan","Feb","Mar","Apr"/)

  res@tmXTOn = False

  res@tmYLMode = "Manual" ; 默认"automatic"
  res@tmYLTickStartF = 0  ; 起始最小刻度值
  res@tmYLTickEndF   = 40 ;最大刻度值
  res@tmYLTickSpacingF = 4 ;刻度间隔
 
  plot = gsn_csm_contour(wks,z,res)
  ;?没有这个函数
  ;plot = ColorNegDashZeroPosCotour(plot, "black", "black", "black") ;正值用黑色实线，负值用虚线
  draw(plot)
  frame(wks)
  
end