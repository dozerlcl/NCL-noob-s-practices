; A simple template for NCL
;-- load function/procedure library
; load加载函数/库文件 V6.2.0或以上默认加载前三个；全部加上向下兼容
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;-- define our own function
; 反定义function或procedure，防止出现同名函数
undef("my function")
; 声明函数和子程序
function my_function(array)
; 声明局部变量
local Min, Max, Avg
begin 
    Min = min(array)
    Max = max(array)
    Avg = avg(aarray)
    return( (/ Min, Max, Avg /) )
end
; --
begin;主要的语句块
; -- generate some dummy data.
nlon    = 144
nlat    = 73
dataMin = -200.
dataMax = 600.
data    = generate_2d_array(10, 10, dataMin, dataMax, 11, (/nlat,nlon/) )
;printVarSummary(data)
;print(data)
lat     = -90. +ispan(0, nlat-1, 1)*2.5 ;创建整型等差数列
lon     = fspan(0, 357.5, nlon) ;创建实型等差数列
; testlat = fspan(-90, 90, nlat)
; print(testlat)
lat@units = "degrees-north";@获取，创建变量的属性
lon@units = "degrees-east"
data!0  ="lat";!获取，创建维度名称
data!1  ="lon"
data&lat = lat;获取，创建变量坐标
data&lon = lon
printVarSummary(data)
delete([/lat,lon/]);删除以防误操作

end
