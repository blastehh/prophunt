local MAP_ZONES_LASER = Material( "cable/redlaser" )
local MAP_ZONES_LASER = Material( "cable/redlaser" )
local MAP_ZONES_POINTS = Material( "cable/blue_elec" )
local MAP_ZONES_POINTS2 = Material( "cable/hydra" )
local MAP_ZONES_POINTS3 = Material( "cable/crystal_beam1" )
local MAP_ZONES_BOX_SIZE = 1
	
function DrawMapZonesBoundingBox( _pos1, _pos2 )
	local _size = MAP_ZONES_BOX_SIZE -- Width of the beam or so...; experiment..
	local _textureStart = 0
	local _textureEnd = 0

	// Outside surfaces
	render.SetMaterial( MAP_ZONES_POINTS )
	render.DrawBeam( _pos1, Vector( _pos1.x, _pos2.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos1, Vector( _pos2.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos2, Vector( _pos2.x, _pos1.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos2, Vector( _pos1.x, _pos2.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos2.x, _pos2.y, _pos1.z ), Vector( _pos1.x, _pos2.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos2.x, _pos2.y, _pos1.z ), Vector( _pos2.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos1.x, _pos1.y, _pos2.z ), Vector( _pos2.x, _pos1.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos1.x, _pos2.y, _pos1.z ), Vector( _pos1.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	

	
	// Shape
	render.SetMaterial( MAP_ZONES_LASER )
	render.DrawBeam( _pos1, Vector( _pos1.x, _pos2.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos1, Vector( _pos2.x, _pos1.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos1, Vector( _pos1.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos2, Vector( _pos2.x, _pos2.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos2, Vector( _pos2.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( _pos2, Vector( _pos1.x, _pos2.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos1.x, _pos1.y, _pos2.z ), Vector( _pos1.x, _pos2.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos1.x, _pos1.y, _pos2.z ), Vector( _pos2.x, _pos1.y, _pos2.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos2.x, _pos1.y, _pos2.z ), Vector( _pos2.x, _pos1.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos1.x, _pos2.y, _pos2.z ), Vector( _pos1.x, _pos2.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos2.x, _pos2.y, _pos1.z ), Vector( _pos1.x, _pos2.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
	render.DrawBeam( Vector( _pos2.x, _pos2.y, _pos1.z ), Vector( _pos2.x, _pos1.y, _pos1.z ), _size, _textureStart, _textureEnd, COLOR_WHITE )
end

function LoadDebugStuff()
	if DEBUG then
		hook.Remove( "PostDrawTranslucentRenderables", "BoundingBoxes")
		hook.Add( "PostDrawTranslucentRenderables", "BoundingBoxes", function( )
			if !DEBUG then hook.Remove( "PostDrawTranslucentRenderables", "BoundingBoxes") return end
			if BSList && #BSList > 0 then
				for k,v in pairs(BSList) do
					DrawMapZonesBoundingBox(v[1],v[2])
				end
			end
			
			if SSList && #SSList > 0 then
				for k,v in pairs(SSList) do
					DrawMapZonesBoundingBox(v[1],v[2])
				end
			end
			
		end )
	end
end

hook.Add( "InitPostEntity", "MapLoadedStuff", LoadDebugStuff )