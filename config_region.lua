-- CONFIG REGION

-- Allows user to create a data structure that defines a region (polygon) on the F-10 map

-- 

-- Format
-- R - Region info
-- R:1
-- name:Example Name assigns region 1 the name "Example Name" (optional)
-- coalition:  													(starting ownership state)
-- 
-- 																
-- V - vertices followed by which region it belongs to and which vertice this is
-- EG:
-- V:1,1
-- V:1,2
-- V:1,3
-- V:1,4
-- Vertices must be specified in clockwise order
--
--
--
-- FL: front line designated point, followed by which regions it connects EG:
-- FL:1,2
-- FL:1,3
--
-- FB: firebase, initializes a firebase in the region (WIP)
-- FARP: if there is a FARP at this FB
-- FB:1
-- FARP: true/false 
--
--
-- OM: Designates an off-map spawn (WIP)
-- name: name of spawn
-- shop: true/false <-- if this spawn will be linked to the shop
-- FARP: true
--
--
-- OOB - out of bounds region
-- OOB:5 (region 5 - must not conflict with regular regions)
-- V:5,1
-- V:5,2
-- V:5,3
-- V:5,4



--

-- Region definitions
--
-- DCS specific



local Marks = {}

package.path = package.path .. ";" .. lfs.writedir() .. "Scripts\\?.lua;"
local JSON = require("JSON")

function generate_region(Mark_Obj)

	trigger.action.outText("Generating Region...", 30)	
	--trigger.action.outText(Mark_Obj.mytable, 30)
	--trigger.action.outText(Mark_Obj.mytable[1].text, 30)
	--trigger.action.outText(Mark_Obj.mytable[1], 30)
	
	Region = {};
	Frontlines = {};
	OffMaps = {};
	
	trigger.action.outText("Outside for", 30)
	
	for Key, Value in pairs(Mark_Obj.mytable) do
		
		trigger.action.outText("Inside for", 30)	
	
		text = Mark_Obj.mytable[Key].text
		trigger.action.outText("text: "..text, 30)
		
		r_table = parse_string(text)
		
		if(r_table.r_type == "FL") then
			
			trigger.action.outText("Inside FL", 30)
			
			r_table.pos = Mark_Obj.mytable[Key].pos
			
			table.insert(Frontlines, r_table)
			
		if(r_table.r_type == "OM") then
			
			trigger.action.outText("Inside OM", 30)
			
			r_table.pos = Mark_Obj.mytable[Key].pos
			
			table.insert(OffMaps, r_table)
		
		elseif(r_table.V_id ~= nil) then -- Add a vertice to Region
			
			if(Region[r_table.name] ~= nil) then	-- if this entry already exists
				
				trigger.action.outText("V_ID"..V_id, 30)
					
				if(Region[r_table.name].Verts == nil) then
					Region[r_table.name].Verts = {} 
				end						
				
				Region[r_table.name].Verts[r_table.V_id] = Mark_Obj.mytable[Key].pos	
			
			else --initialize it
				
				Region[r_table.name] = {}
				Region[r_table.name].Verts = {} 
				Region[r_table.name].Verts[r_table.V_id] = Mark_Obj.mytable[Key].pos
				
			end
			
			
		elseif(r_table.r_type == "R") then --Region properties 
			
			Region[r_table.name].r_type = r_table.r_type
			
		elseif(r_table.r_type == "OOB") then --Out of bounds region properties 
			
			Region[r_table.name].r_type = r_table.r_type
			
		elseif(r_table == nil) then
		
			trigger.action.outText("INVALID INPUT", 30)
		
			return nil
		
		end
		

	end
	
	Region.Frontlines = Frontlines
	Region.OffMaps = OffMaps
	
	table.save(Region, lfs.writedir().."\\Scripts\\config_region\\Region.lua")
	
end

function parse_string(myString)
		
	trigger.action.outText("In Parse String...", 30)	
	
	first = string.match(myString, "%a+") -- returns everything up to the :
	second = string.match(myString, "%p.+") -- returns everything after the :
	
	trigger.action.outText(tostring(first), 30)	
	
	region_table = {}
	
	
	if(first == "R") then-- Region info
		trigger.action.outText("R", 30)	
				
		R_name = second:match("%p.+"):sub(2)

		
		region_table = {r_type = "R",
						name = R_name,
						}

	elseif(first == "V") then -- Vertice of a region
			
		trigger.action.outText("V", 30)	
			
		R_name = second:match("%p%d+"):sub(2) -- sub 2 to remove colon
		V_id = second:sub(2):match("%p%d+"):sub(2)  -- sub 2 to remove colon then to remove comma
		
		trigger.action.outText("V_ID"..V_id, 30)
		
		region_table = {V_id = V_id,
						name = R_id,
						}
	
	elseif(first == "FL") then -- Location of a frontline
				
		trigger.action.outText("FL", 30)	
				
		R1_id = second:match("%p%d+"):sub(2) -- sub 2 to remove colon
		R2_id = second:sub(2):match("%p%d+"):sub(2)  -- sub 2 to remove colon then to remove comma
				
		region_table = {r_type = "FL",
						R1 = R1_name,
						R2 = R2_name,
						}
						
	elseif(first == "OM") then -- Location of an off-map point
				
		trigger.action.outText("OM", 30)	
		
		OM_id = second:match("%p.+"):sub(2)
				
		region_table = {r_type = "OM",
						name = OM_id
						}
		
	elseif(first == "FB") then -- Location of a firebase
	
		trigger.action.outText("FB", 30)	
	-- not implemented (yet)
		
	elseif(first == "OOB") then -- Vertice of an out of bounds region
	
		trigger.action.outText("OOB", 30)	
		R_name = second:match("%p.+"):sub(2)
		
		region_table = {r_type = "OOB",
						name = R_name,
						}

	else -- invalid string
	
		trigger.action.outText("None", 30)	
	
		return nil
				
	end
	
	return region_table

end


-- Marks definitions

function Marks:new()
	
   setmetatable({}, self)
   self.mytable = {};
   self.idtable = {};
   self.idstart = 1;
   
   trigger.action.outText("new", 30)
   
   return self;

end

function Marks:modify(id, text, pos)
	
	if(self.idtable[id] ~= nil) then
		my_id = self.idtable[id]  -- just for anal retentiveness, so my table starts at 1, not whatever id DCS assigns it
		
		self.mytable[my_id] = {text = text,
					   pos = pos,
					   }
			
		trigger.action.outText("modify", 30)
		trigger.action.outText(id, 30)
		trigger.action.outText(self.mytable[my_id].text, 30)
	
	else
	
		trigger.action.outText("new", 30)
		
		my_id = self.idstart
		
		self.idtable[id] = my_id
		self.idstart = self.idstart+1
		
		
		self.mytable[my_id] = {text = text,
					   pos = pos,
					   }
		
	end
		
end

function Marks:remove(id)

	my_id = self.idtable[id]  -- just for anal retentiveness, so my table starts at 1, not whatever id DCS assigns it
	self.idtable[id] = nil
	
	self.mytable[my_id] = nil;
		
	trigger.action.outText("delete", 30)
	trigger.action.outText(id, 30)
	trigger.action.outText(my_id, 30)

end


Mark_Obj = Marks:new();

local handler = {}

function handler:onEvent(event)
    if event.id == world.event.S_EVENT_MARK_REMOVE then
        Mark_Obj:remove(event.idx)
    elseif event.id == world.event.S_EVENT_MARK_CHANGE then
       	Mark_Obj:modify(event.idx, event.text, event.pos)
    elseif event.id == world.event.S_EVENT_MARK_ADDED then
       	Mark_Obj:modify(event.idx, event.text, event.pos)		
    end
end

world.addEventHandler(handler)
missionCommands.addCommand("Done Region Config", nil, generate_region, Mark_Obj); 

local function exportstring( s )
  return string.format("%q", s)
end

--// The Save Function
function table.save(  tbl,filename )
  local charS,charE = "   ","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
	 file:write( "-- Table: {"..idx.."}"..charE )
	 file:write( "{"..charE )
	 local thandled = {}

	 for i,v in ipairs( t ) do
		thandled[i] = true
		local stype = type( v )
		-- only handle value
		if stype == "table" then
		   if not lookup[v] then
			  table.insert( tables, v )
			  lookup[v] = #tables
		   end
		   file:write( charS.."{"..lookup[v].."},"..charE )
		elseif stype == "string" then
		   file:write(  charS..exportstring( v )..","..charE )
		elseif stype == "number" then
		   file:write(  charS..tostring( v )..","..charE )
		end
	 end

	 for i,v in pairs( t ) do
		-- escape handled values
		if (not thandled[i]) then
		
		   local str = ""
		   local stype = type( i )
		   -- handle index
		   if stype == "table" then
			  if not lookup[i] then
				 table.insert( tables,i )
				 lookup[i] = #tables
			  end
			  str = charS.."[{"..lookup[i].."}]="
		   elseif stype == "string" then
			  str = charS.."["..exportstring( i ).."]="
		   elseif stype == "number" then
			  str = charS.."["..tostring( i ).."]="
		   end
		
		   if str ~= "" then
			  stype = type( v )
			  -- handle value
			  if stype == "table" then
				 if not lookup[v] then
					table.insert( tables,v )
					lookup[v] = #tables
				 end
				 file:write( str.."{"..lookup[v].."},"..charE )
			  elseif stype == "string" then
				 file:write( str..exportstring( v )..","..charE )
			  elseif stype == "number" then
				 file:write( str..tostring( v )..","..charE )
			  end
		   end
		end
	 end
	 file:write( "},"..charE )
  end
  file:write( "}" )
  file:close()
end
