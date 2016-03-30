-- BSList format: Vector(X position) , Vector(Y Position) , "Name of spot" , true/false(instakill for being there)
BSList = {
	{ Vector(3632,6100,-880), Vector(4773,7580,-600), "01", true },
	{ Vector(4804,5637,-863), Vector(4866,6092,-600), "02", true },
	{ Vector(4780,6587,-880), Vector(4833,6724,-600), "03", true },
	{ Vector(5545,6703,-511), Vector(6475,7253,-400), "04", true },
	{ Vector(4576,5475,-863), Vector(4580,5539.5,-820), "05", false },
	{ Vector(5311,7270,-858), Vector(5379,7275,-813), "DogDumpster", false },
	{ Vector(5364,3570,-733), Vector(5540,3657,-718), "07", false },
	{ Vector(6516,4204,-861), Vector(6762,4323,-741), "FrontDoorCage", false },
	{ Vector(4792,4100,-861), Vector(4987,4218,-741), "BackAlleyCage", false },
	{ Vector(5723,3804,-466), Vector(5728,4381,-358), "Rafter", false },
	{ Vector(5723,4381,-395), Vector(5728,4429,-374), "Rafter2", false },
	{ Vector(5723,4429,-404), Vector(5728,4477,-384), "Rafter3", false },
	{ Vector(5723,4477,-416), Vector(5728,4525,-396), "Rafter4", false },
	{ Vector(5723,4525,-429), Vector(5728,4573,-409), "Rafter5", false },
	{ Vector(5723,4573,-437), Vector(5728,4621,-417), "Rafter6", false },
	{ Vector(5723,4621,-449), Vector(5728,4669,-429), "Rafter7", false },
	{ Vector(6772,4009,-607), Vector(6827,4194,-496), "HostageRoomCage", false },
	{ Vector(5949,6092,-822), Vector(5979,6094,-802), "Window01", false },
	{ Vector(4926,6703,-835), Vector(5277,6724,-792), "Window02", false },
	{ Vector(6252,6088,-855.97), Vector(6307,6093,-848), "Door01", false },
	{ Vector(6620,7268,-960), Vector(6876,7887,-780), "Tunnel01", false },
	{ Vector(5140.18,4960,-831), Vector(5268,4972,-815), "LoadingDoor", false },
	{ Vector(5970,4802,-450), Vector(5980,4831,-436), "Aircon", false },
	{ Vector(5390,3937.5,-831.97), Vector(5397,3943,-820), "Boxes", false },
	-- back of map :(
	{ Vector(6444,3781,-474), Vector(6961,4196,-262), "Storage room roof", true }, -- storage roof
	{ Vector(5008.03,4220.03,-365.77), Vector(6447.97,4373.97,-50), "Back roof front", true }, -- Roof front side
	{ Vector(2272.03,2944.03,-879.97), Vector(6960.97,3543,-50), "Floor to sky", true }, -- floor to sky
	{ Vector(6464.03,3563,-879.97), Vector(6960.97,4191,-620.55), "Floor to tank", true }, --  floor to tank
	{ Vector(6830.03,3804,-620.6), Vector(6960.97,4190,-473.9), "Tank mid-air", true },
	{ Vector(6444.03,3543,-620.6), Vector(6960.97,3773.9,-473.9), "Tank mid-air further back", true },
	{ Vector(5004.03,3781,-449), Vector(5722.97,4072.68,-262), "Back roof vent side1", true }, --  Roof back side vent
	{ Vector(5815,3781,-440), Vector(6444,4072.68,-262), "Back roof vent side2", true }, --  Roof back side vent
	{ Vector(5722.97,3781,-375.97), Vector(5805,4072.68,-50), "Back roof top of vent", true }, --  Roof back side vent
	{ Vector(2272.03,3563,-879.97), Vector(6444.03,3663.97,-740.03), "Under back roof", true }, --  Floor under back of roof  
	{ Vector(2272.03,3663.97,-879.97), Vector(4990,4083.97,-50), "Under back room cage", true }, --  Floor under back of roof hostage cage
	{ Vector(2272.03,3563,-456), Vector(6960.97,3781,-50), "Back roof edge", true }, --  Roof back side edge
	{ Vector(5004.03,3781,-395.1), Vector(5719.97,4220.03,-50), "Back roof mid", true }, --  Roof back mid
	{ Vector(2272.03,4083.97,-255.97), Vector(4703.23,5627.97,-50), "Back roof to watertower", true }, --  Roof watertower side 
}

-- SSList (snow checker) format: Vector(X position) , Vector(Y Position) , true/false kill for the spot if true, otherwise just ignite.
SSList = {
	{ Vector(7182,4213,-543), Vector(7190,7254,-542), false },
	{ Vector(7261,4213,-543), Vector(7271,7254,-542), false },
}