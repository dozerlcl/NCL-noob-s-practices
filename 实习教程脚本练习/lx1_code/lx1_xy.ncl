;绘制一根折线
begin
  y = sin(0.0628*ispan(0,100,1))     
  
  wks = gsn_open_wks("x11","xy_ex")  

  res = True                                     
  res@xyLineColor    =    1 ;通常而言，1表示背景色为黑色，0表示背景色为白色
  res@xylinethicknessF    =    4.5 ;4.5倍粗
  res@xyMarkLineMode    =    "MarkLines" ;用点线绘制折线
  res@xyMarker    =    16 ;
  res@xyMarkerColor    =    "black" ;点的颜色
  plot = gsn_csm_y(wks,y,res)                                              
end