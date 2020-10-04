;3.25 实验obs 和 mod 放反之后的taylor_stats的计算是否正确
begin

path_out_1 = "./practice/bc_data/temporary_data/bc_tm/taylor/taylor_regcm_test1"+".nc"
path_out_2 = "./practice/bc_data/temporary_data/bc_tm/taylor/taylor_regcm_test2"+".nc"
f_1 = addfile(path_out_1, "r")
f_2 = addfile(path_out_2, "r")
file_num = 2
bc_o = new((/file_num,8/),"float")
mod_o = new((/file_num,8/),"float")

bc_o(0,:) = f_1->$"stats_bc"$
mod_o(0,:)    = f_1->$"stats_mod"$

bc_o(1,:) = f_2->$"stats_bc"$
mod_o(1,:)    = f_2->$"stats_mod"$

print(bc_o(0,:))
print(mod_o(0,:))
print(bc_o(1,:))
print(mod_o(1,:))
end