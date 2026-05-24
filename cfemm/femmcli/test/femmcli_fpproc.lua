-- femmcli_fpproc.lua
-- This test is basically the same as running fmesher and fsolver on the .fem file.
-- The file femmcli_femfile.fem is the same as cfemm/fsolver/test/Temp.fem
-- SUCCESS
showconsole()

-- check variable <name>,
-- compare <value> against <expected> value
-- if the relative difference is greater than the margin (in percent), complain and return 1
function check(name, value, expected, margin)
	diff=100*(value - expected) / expected
	if abs(diff) > margin then
		fail=1
		result="[FAILED] "
	else
		fail=0
		result="[  ok  ] "
	end
	print(result .. name .. ": " .. value .. " (expected: " .. expected .. ", diff: " .. diff .. "%, margin: " .. margin .. "%)")
	--print("check(\""..name.."\", "..name..", "..value..", "..margin..")")
	return fail
end

function check_abs(name, value, expected, margin)
	diff=value - expected
	if abs(diff) > margin then
		fail=1
		result="[FAILED] "
	else
		fail=0
		result="[  ok  ] "
	end
	print(result .. name .. ": " .. value .. " (expected: " .. expected .. ", diff: " .. diff .. ", margin: " .. margin .. ")")
	return fail
end

-- enable for additional output:
-- XFEMM_VERBOSE = 1

open("femmcli_fpproc.fem")
mi_analyze()
mi_loadsolution()

-- This point is near a material boundary. A/B/E are stable across platforms,
-- but triangle tie-breaking can select either adjacent material for H/Mu.
sample_x = 0.2501
sample_y = 1e-6
A,B1,B2,Sig,E,H1,H2,Je,Js,Mu1,Mu2,Pe,Ph = mo_getpointvalues(sample_x, sample_y)

-- check result against FEMM42 output:
-- FIXME: error margin needs sane values
failed=0
failed = failed + check("A", A, 1.245741227364988e-014, 2)
failed = failed + check("B1", B1, -9.855007421888915e-014, 2)
failed = failed + check("B2", B2, 3.052725906923963e-014, 2)
failed = failed + check("Sig", Sig, 0, 2)
failed = failed + check("E", E, 4.235125240802008e-021, 3)
failed = failed + check("Je", Je, 0, 2)
failed = failed + check("Js", Js, 0, 2)
failed = failed + check_abs("H1", H1, B1/(Mu1*uo), 1e-18)
if Mu2 > 1e100 then
	failed = failed + check_abs("H2", H2, 0, 1e-18)
else
	failed = failed + check_abs("H2", H2, B2/(Mu2*uo), 1e-18)
end
failed = failed + check("Pe", Pe, 0, 2)
failed = failed + check("Ph ", Ph , 0, 2)

assert(failed==0)
write("SUCCESS\n")
