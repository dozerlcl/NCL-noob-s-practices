; 4.1 用于检查heat plot的输出 mask模板
;   南热区没有数据
begin
  type = "tm" 
  check_num = 10
  path_rmse = "./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/"+type+"_rmse_bind_"+check_num+".nc"
  f_rmse = addfile(path_rmse, "r")
  mod_rmse = f_rmse->$"mod_rmse"$
  bc_rmse  = f_rmse->$"bc_rmse"$
  print(mod_rmse)
  print(bc_rmse)
end