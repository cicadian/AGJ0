/// @func world_build
/// @desc {void} builds the game world grid
function world_build(){
	tile_to_grid(LAYER_NAME_PATH, global.world_grid, __CELL_PATH.EMPTY);
	global.light_ambient = AMBIENT_LIT;
	world_light_vbuff = vertex_create_buffer();
	vertex_begin(world_light_vbuff, world_format);
	var _vbuff = world_light_vbuff;
	for (var _h = 0; _h < NATIVE_H div CELL_SIZE; _h++){
		for (var _w = 0; _w < NATIVE_W div CELL_SIZE; _w++){
			world_build_cell(_w, _h, _vbuff);
		}
	}
	vertex_end(world_light_vbuff);
	vertex_freeze(world_light_vbuff);
	with (oDoor){
		door_build();
	}
	with (oClickzone){
		clickzone_build(id);
	}
}
/// @func world_build_dark
/// @desc {void} builds the dark game world grid
function world_build_dark(){
	global.light_ambient = AMBIENT_DARK;
	world_dark_vbuff = vertex_create_buffer();
	vertex_begin(world_dark_vbuff, world_format);
	var _vbuff = world_dark_vbuff;
	for (var _h = 0; _h < NATIVE_H div CELL_SIZE; _h++){
		for (var _w = 0; _w < NATIVE_W div CELL_SIZE; _w++){
			world_build_cell(_w, _h, _vbuff);
		}
	}
	vertex_end(world_dark_vbuff);
	vertex_freeze(world_dark_vbuff);
	oCont_World.world_vbuff = world_dark_vbuff;
	//with (oDoor){
	//	door_build();
	//}
	//with (oClickzone){
	//	clickzone_build(id);
	//}
}

/// @func world_build_cell
/// @desc {void} builds a world cell
/// @arg {real} grid_x
/// @arg {real} grid_y
/// @arg {real} vbuff
function world_build_cell(_grid_x, _grid_y, _vbuff){
	for (var _i = 0; _i < __CELL_WALLS.SIZE; _i++){
		var _is_empty = global.world_grid[# _grid_x, _grid_y] == __CELL_PATH.EMPTY;
		var _build = true;
		var _u = oCont_World.texcoord_default_u;
		var _v = oCont_World.texcoord_kestrel_v;
		var _clickzone_id = instance_position(_grid_x * CELL_SIZE, _grid_y * CELL_SIZE, oClickzone);
		if (_is_empty){
			if (_clickzone_id != noone){
				if (_clickzone_id.wall == _i){
					_build = false;
				}
			}
			if (_build){
				var _layer = layer_get_id("tile_paint");
				var _tileMap = layer_tilemap_get_id(_layer);
				var _tile = tilemap_get(_tileMap, _grid_x, _grid_y);
				switch (_tile){
					case 1:
						_v = oCont_World.texcoord_kestrel_v;
						break;
					case 2:
						_v = oCont_World.texcoord_station_v;
						break;
					case 3:
						_v = oCont_World.texcoord_cargo_v;
						break;
				}
				switch (_i){
					case __CELL_WALLS.EAST:
					case __CELL_WALLS.NORTH:
					case __CELL_WALLS.SOUTH:
					case __CELL_WALLS.WEST:
						_u = oCont_World.texcoord_wall_u;
						break;
					case __CELL_WALLS.TOP:
						_u = oCont_World.texcoord_ceiling_u;
						break;
					case __CELL_WALLS.BOTTOM:
						_u = oCont_World.texcoord_floor_u;
						break;
				}
				world_build_wall(_grid_x, _grid_y, _i, _vbuff, _u, _v);
			}
		}
	}
}

/// @func world_build_wall
/// @desc {void} builds a world cell wall
/// @arg {real} grid_x
/// @arg {real} grid_y
/// @arg {real} type
/// @arg {vbuff} vbuff
/// @arg {real} u
/// @arg {real} v
function world_build_wall(_grid_x, _grid_y, _type, _vbuff, _u, _v){
	var _x1 = _grid_x * CELL_SIZE;
	var _x2 = _x1 + CELL_SIZE;
	var _y1 = _grid_y * CELL_SIZE;
	var _y2 = _y1 + CELL_SIZE;
	var _z1 = 0;
	var _z2 = CELL_SIZE; 
	var _build = false;
	var _lightlevel = global.light_ambient;
	var _color = make_colour_rgb(_lightlevel * 255, _lightlevel * 255, _lightlevel * 255);

	switch(_type){
		case __CELL_WALLS.NORTH:
			_build = !pathgrid_get_empty(_grid_x, _grid_y - 1);
			if (object_index == oClickzone){
				if (type == __CLICKZONE_TYPE.CAPTAIN){
					_build = true; // The captain clickzone exists as a special wall
				}
			}
			if (_build){
				vertex_position_3d(_vbuff, _x1, _y1, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y1, _z2);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y1, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);

				vertex_position_3d(_vbuff, _x1, _y1, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y1, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y1, _z1);
				vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
			}
			break;
		case __CELL_WALLS.EAST:
			_build = !pathgrid_get_empty(_grid_x + 1, _grid_y);
			if (_build){
				vertex_position_3d(_vbuff, _x2, _y1, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y2, _z2);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y2, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);

				vertex_position_3d(_vbuff, _x2, _y1, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y2, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y1, _z1);
				vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
			}
			break;
		case __CELL_WALLS.SOUTH:
			_build = !pathgrid_get_empty(_grid_x, _grid_y + 1);
			if (_build){
				vertex_position_3d(_vbuff, _x2, _y2, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y2, _z2);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y2, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);

				vertex_position_3d(_vbuff, _x2, _y2, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y2, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x2, _y2, _z1);
				vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
			}
			break;
		case __CELL_WALLS.WEST:
			_build = !pathgrid_get_empty(_grid_x - 1, _grid_y);
			if (_build){
				vertex_position_3d(_vbuff, _x1, _y2, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y1, _z2);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y1, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);

				vertex_position_3d(_vbuff, _x1, _y2, _z2);
				vertex_texcoord(_vbuff, _u, _v);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y1, _z1);
				vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
				vertex_position_3d(_vbuff, _x1, _y2, _z1);
				vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
				vertex_colour(_vbuff, _color, 1);
			}
			break;
		case __CELL_WALLS.TOP:
			vertex_position_3d(_vbuff, _x1, _y1, _z2);
			vertex_texcoord(_vbuff, _u, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y1, _z2);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y2, _z2);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);

			vertex_position_3d(_vbuff, _x1, _y1, _z2);
			vertex_texcoord(_vbuff, _u, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y2, _z2);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x1, _y2, _z2);
			vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);
			break;
		case __CELL_WALLS.BOTTOM:
			vertex_position_3d(_vbuff, _x1, _y1, _z1);
			vertex_texcoord(_vbuff, _u, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y1, _z1);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y2, _z1);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);

			vertex_position_3d(_vbuff, _x1, _y1, _z1);
			vertex_texcoord(_vbuff, _u, _v);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x2, _y2, _z1);
			vertex_texcoord(_vbuff, _u + oCont_World.tex_spr_uvs, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);
			vertex_position_3d(_vbuff, _x1, _y2, _z1);
			vertex_texcoord(_vbuff, _u, _v + oCont_World.tex_spr_uvs);
			vertex_colour(_vbuff, _color, 1);
			break;
	}
}

/// @func world_cleanup
/// @desc {void} frees memory of the game world
function world_cleanup(){

}