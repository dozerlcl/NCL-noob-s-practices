begin
  ;生成四组随机数
  data1 = generate_2d_array(10, 12, -20., 17., 0, (/129,129/))
  data2 = generate_2d_array(13, 13, -25., 15., 1, (/129,129/))
  data3 = generate_2d_array(10, 10, -22., 16., 2, (/129,129/))
  data4 = generate_2d_array( 9, 10, -23., 15., 3, (/129,129/))

  plot = new(4,graphic)  
  wks = gsn_open_wks("x11","panel_lx1")   
  gsn_define_colormap(wks, "gsdtol") ;使用灰度色板gsltod
  
  res                     = True
  res@gsnFrame            = False
  res@gsnDraw             = False
  
  res@cnFillOn            = True       
  res@cnLinesOn           = True      
  res@cnLineLabelsOn       = False  
  res@cnInfoLabelOn        = False 
    
  ;指定需绘制等值线，这样才能只用一个公用的labelbar
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-24,-20,-18,-15,-11,-7,-3,-1,2,5,7,10,13,16/)  
  res@lbLabelBarOn         = False ;关闭每个图形各自的色标，以公用的一个色标 

  plot(0) = gsn_csm_contour(wks,data1,res)
  plot(1) = gsn_csm_contour(wks,data2,res)
  plot(2) = gsn_csm_contour(wks,data3,res)
  plot(3) = gsn_csm_contour(wks,data4,res)  

  pres = True
  pres@txString              = "Paneling"
  pres@gsnPanelLabelBar      = True ; 公用一个色标
  pres@gsnPanelFigureStrings = (/"A","B","C","D"/)
  pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/2,2/),pres)

end