begin
  fu = addfile("./practice/lx1_data/u850-197901-201412.nc","r")
  fv = addfile("./practice/lx1_data/v850-197901-201412.nc","r")

  u = short2flt(fu->uwnd(0,{850},:,:)) ; 仅挑取第0个时次      
  v = short2flt(fv->vwnd(0,{850},:,:))
  printVarSummary(u)
  printVarSummary(v)
  ; 将u，v减少点维度?直接收窄点区域好了

  wks = gsn_open_wks("x11","vector_ex") 

  res                      = True          ; Plot options desired.
  res@gsnLeftString        = ""
  res@gsnRightString       = ""
  
  res@pmTickMarkDisplayMode = "Always" 
  
  res@vcGlyphStyle         = "FillArrow" ;  选择箭头线型"CurlyVector" , "WindBarb"   

  res@vcFillArrowEdgeColor     = "white" ; 箭头边缘颜色
  res@vcfillarrowfillcolor     = "black" ; 箭头内部填充颜色
  res@vcMinMagnitudeF          = 5.0     ; 小于5则不再绘制
  res@vcMinDistanceF           = 0.02    ;设定箭头之间的最小距离（在单位坐标系中），防止过密或者过疏


  ;; 箭头头部大小一致。若要绘制头部大小不一致箭头可参考第4章示例。
  res@vcFillArrowMinFracWidthF = 1.0 
  res@vcFillArrowHeadMinFracXF = 1.0  
  res@vcFillArrowHeadMinFracYF = 1.0 
  
  ;; 参考箭头
  res@vcRefAnnoOn               = True  
  res@vcRefMagnitudeF           = 20      ;标准长度箭头所表示的实际物理量大小
  res@vcRefLengthF              = 0.04   ;标准长度箭头在图形中的长度
  res@vcRefAnnoBackgroundColor  = "white" ;背景颜色     
  res@vcRefAnnoPerimOn          = False   ;关闭边框   
  res@vcRefAnnoFontHeightF      = 0.015   ;参考箭头标签字体大小      
  res@vcRefAnnoString1On        = False   ;不设定参考箭头上方字符        
  res@vcRefAnnoString2On        = True    ;设定参考箭头下方的字符
  res@vcRefAnnoString2          = "20 m/s"  
  res@vcRefAnnoOrthogonalPosF   = -1.25   ;垂直移动其距离
  ;   ;; 绘制的地图区域
  ; res@mpMinLatF    = 10          
  ; res@mpMaxLatF    = 80
  ; res@mpMinLonF    = 30
  ; res@mpMaxLonF    = 130
   plot  = gsn_csm_vector_map(wks,u,v,res)
end