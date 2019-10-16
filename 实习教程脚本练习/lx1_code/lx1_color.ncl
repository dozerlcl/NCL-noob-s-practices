begin
  f = addfile("./practice/lx1_data/air.mon.mean.nc","r")
  var = short2flt(f->air(0,:,:,:)) ;此处仅读取第一个时次的air值
  var_test = short2flt(f->air(:,:,:,:)) ; [time | 753] x [level | 17] x [lat | 73] x [lon | 144]
  printVarSummary(var)
  printVarSummary(var_test)
  wks = gsn_open_wks("x11","color")              
  gsn_define_colormap(wks,"hotcold_18lev") ;将默认色板更换为"hotcold_18lev"

  res = True
  res@gsnAddCyclic   = True
  res@cnFillOn       = True
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加 度 符号

  res@gsnLeftString = "" ;不绘制左标题
  res@gsnRightString= "" ;不绘制右标题
      
  ;;; 指定要绘制的等值线及填充的颜色
  ;没有起作用？
  ; res@cnLevelSelectionMode  = "ExplicitLevels"
  ; res@cnlevels              = (/-35,-25,-15,-5,5/)
  ; res@cnFillColors          = (/2,4,6,8,11,13/)
  
  ; Draw 5 equally spaced contours between min(x)+CI and max(x)-CI.
; CI = contour interval calculated by NCL
;
  res@cnMaxLevelCount      = 5
  res@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels

  plot = gsn_csm_contour_map_ce(wks,var({700},:,:),res) ;指定作图维度  
  ;---To retrieve the levels NCL used, use "getvalues"
  getvalues plot@contour
    "cnLevels" : levels
  end getvalues
  print("levels = " + levels)

end                     
end

