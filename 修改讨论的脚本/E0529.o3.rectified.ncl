begin
;>>step1读入部分
;f=addfiles("/home/hongwj/05x0625.o3.2014/0529/ts.2014*.*.nc","r")
;data=asciiread("/home/shangyj/nclshixi/shixi9_merra2_O3/station.txt",(/24,3/),"float")      
;6.8日江苏各个站点的臭氧浓度txt文件
;dir_sim  ="/home/hongwj/05x0625.o3.2014/0529/"
dir_sim = "./test/0529/"
nc_files = systemfunc("ls "+dir_sim+"ts.2014*.*.nc"); 批量读入文件systemfunc('ls'+"文件名共同部分.*.nc")
f = addfiles(nc_files,"r")
ListSetType(f,"join"); 打开多个文件并且返回文件句柄
printVarSummary(f); f的连接类型位join，listsettype进行了修改
list_filevars(f[0]); 看下文件句柄中的变量,需要用的就是IJ-AVG-S__O3，LON,LAT
print(getfilevaratts(f[0],"IJ-AVG-S__O3"));处理的臭氧变量，变量名IJ-AVG-S__O3
O3=f[:]->$"IJ-AVG-S__O3"$;将臭氧8小时平均中的臭氧值赋值
lat=f[0]->$"LAT"$;list_filevars查询到变量最下面含有lat和lon两个变量
lon=f[0]->$"LON"$;读入一个文件的维度就行了，不然会有24个
printVarSummary(O3)
print("-------------------------------------完成文件读入-------------------------------------")
;>>step2计算部分
data = O3; 直接赋值，和O3的属性一致（别用data这种名字，多谢角标，方便一世（不
o3chuli = new((/133,145/),float)
printVarSummary(data); 检查下data属性,第一个维度，维度0，是[ncl_join|24];从24个文件中读取，即是时次
;///这段太长了
; do i=0,132
;   do j=0,144
;     maxeight = runave_Wrap(data(:,i,j),8,0)
;     printVarSummary(maxeight)
;     ; maxdaily = dim_max_n(maxeight(:,i,j),1)
;     ; o3chuli(i,j)=maxdaily
;   end do
; end do
;///太长不看
max_eight_runave = runave_n_Wrap(data, 8, 0, 0) ; 对第1个维度（24）做滑点为8的滑动平均
o3chuli = dim_max_n(max_eight_runave, 0); 命名好听点（方便文本编译器补全字段，多用下划线
printVarSummary(max_eight_runave)
;检查下结果，别在ncl这种解释语言里面写这么多循环啊!（很慢的(调用些外部函数更好
;>>step3设置输出维度部分
;之前的LAT,LON两个变量保存了维度信息,将他们
printVarSummary(lat)
printVarSummary(lon)
o3chuli!0 = "lat"
o3chuli&lat = lat
o3chuli!1 = "lon"
o3chuli&lon = lon
printVarSummary(o3chuli) ;最后检查一遍
;>>step4绘图要素
    wks=gsn_open_wks("x11","O3_8hr_avg_shixi9")   
    gsn_define_colormap(wks,"BlueDarkRed18")
    
    res=True
    res@gsnFrame=False
    res@sfXCStartV=min(lon)
    res@sfXCEndV=max(lon)
    res@sfYCStartV=min(lat)
    res@sfYCEndV=max(lat)
    res@tiMainString="Ozone concentration_Jiangsu.2014.6.8"
    res@gsnRightString="~F33~m~F25~g/m~S~3~N~"
    res@tiMainFontHeightF=0.02
    res@tiMainFontColor="black"
    res@pmTickMarkDisplayMode="Always"
    res@mpMinLatF=20
    res@mpMaxLatF=45
    res@mpMinLonF=108
    res@mpMaxLonF=125
 res@mpDataBaseVersion = "Ncarg4_1"   ;地图采用中等分辨率
    res@mpDataSetName="Earth..4"

    res@mpOutlineOn=True
    res@mpOutlineSpecifiers=(/"China:states","Taiwan"/)
    res@mpFillOn=False
    res@gsnAddCyclic=False

    res@mpGridAndLimbOn=True             ;设置经纬线
    res@mpGridLineThicknessF=0.5
    res@mpGridLineDashPattern=0.5
    res@mpGridLineDashPattern=2
    res@mpGridSpacingF=10

    res@cnFillOn=True                   
    res@cnLinesOn=False
    res@cnLevelSelectionMode="ExplicitLevels"                  ;绘制指定的等值线和填充的颜色
    res@cnLevels=(/20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180/)
    res@cnFillColors=(/2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/)
    plot=gsn_csm_contour_map(wks,o3chuli,res)
;最后无法理解的打点图
colors=(/2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/)
    gsres=True
    do i=0,23
        do j=0,17
            if(o3chuli(i,2).ge.(j+2)*10.and.o3chuli(i,2).lt.(j+3)*10) then
                gsres@gsMarkerIndex=16
                gsres@gsMarkerColor=colors(j+1)
                gsres@gsMarkerSizeF=8
                gsn_polymarker(wks,plot,lon(i),lat(i),gsres)
            end if
        end do 
    end do

    pmres=True
    pmres@gsMarkerColor="black"
    pmres@gsMarkerIndex=4
    pmres@gsMarkerSizeF=9
    do i=0,23
    gsn_polymarker(wks,plot,lon(i),lat(i),pmres)
    end do
    frame(wks)


end