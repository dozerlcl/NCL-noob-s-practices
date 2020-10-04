begin
  npts = 500
  y = 500.+.9* ispan(0,npts-1,1)*sin(0.031415926535898*ispan(0,npts-1,1))
  printVarSummary(y)
  wks = gsn_open_wks("x11","title_ex")  

  res = True                          
  res@tiMainString              = "this is a main title" ;添加主图题
  res@tiMainFontHeightF         = 0.05 ;主图题字体大小
  res@timainfoncolor            = "black" ;主图题字体颜色
  res@gsnCenterString           ="Center String" ;添加中间标题
  res@gsnLeftString             ="Left String" ;添加左标题
  res@gsnRightString            ="Right String" ;添加右标题

  res@tiXAxisString             ="X Axis" ;添加X轴名称
  res@tiYAxisString             ="Y Axis" ;添加Y轴名称
  res@tiXAxisFontHeightF        =0.03 ;X/Y轴名称的字体大小 
  res@tiXAxisFontColor          ="black" ;X/Y轴名称的字体颜色

  plot = gsn_csm_y(wks,y,res)
end