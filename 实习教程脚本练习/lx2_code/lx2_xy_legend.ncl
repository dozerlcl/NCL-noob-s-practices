begin
  npts = 500
  x    = fspan(-100,100,npts)   ; 500 values from -100 to 100.
  y    = new((/4,500/),"float") ;创建一个2d数组，用以表示4根这西安
  y(0,:) = sin(0.0628*x)     
  y(1,:) = cos(0.0628*x) 
  y(2,:) = cos(0.0628*x)*sin(0.0628*x)  
  y(3,:) = cos(0.0628*x)+sin(0.0628*x)  
    
  wks = gsn_open_wks("x11","xy_legend_ex") 

  res = True                         
  ;坐标轴的取值范围
  res@trXMinF           = min(x)             
  res@trXMaxF           = max(x)
  res@trYMinF           = min(y)-0.2   ;留空白,绘制图例
  res@trYMaxF           = max(y)+0.6   ;
  
  res@xyLineThicknesses = (/1,2,3,4/) ;不同的粗细
  res@xyLineColor       = (/"black","black","black","black"/) ;
  res@xyDashPattern     = (/0,2,4,6/) ;不同的线型

  ;图例说明
  res@pmLegendDisplayMode = "Always" ; 添加图例
  res@xyExplicitLabels = (/"1","2","3","4"/) ; 每根折线的名称
  res@pmLegendWidthF = 0.2 ;图例的宽度
  res@pmLegendHeightF = 0.1 ;图例的高度
  res@pmLegendOrthogonalPosF = -1.05 ;图例的垂直移动量
  res@pmLegendParallelPosF = 0.82 ;图例的水平移动量   

  plot = gsn_csm_xy(wks,x,y,res)  
end