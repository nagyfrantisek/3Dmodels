// https://makerworld.com/en/models/1181937-customizable-bottle

/* [Parameters] */
neck_thread = "PCO-1810"; // [PCO-1810, PCO-1881]
diameter = 40; //[0:250]
body_cylinder_height = 25; //[0:250]
body_cone_height = 15; //[1:250]
neck_height = 2; //[0:250]
height=body_cylinder_height+body_cone_height;
wall_thickness = 1.2;

/* [Hidden] */
$fn=120;

// cross and norm are builtins
//function cross(x,y) = [x[1]*y[2]-x[2]*y[1], x[2]*y[0]-x[0]*y[2], x[0]*y[1]-x[1]*y[0]];
//function norm(v) = sqrt(v*v);

function vec3(p) = len(p) < 3 ? concat(p,0) : p;
function vec4(p) = let (v3=vec3(p)) len(v3) < 4 ? concat(v3,1) : v3;
function unit(v) = v/norm(v);

function identity3()=[[1,0,0],[0,1,0],[0,0,1]]; 
function identity4()=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]];


function take3(v) = [v[0],v[1],v[2]];
function tail3(v) = [v[3],v[4],v[5]];
function rotation_part(m) = [take3(m[0]),take3(m[1]),take3(m[2])];
function rot_trace(m) = m[0][0] + m[1][1] + m[2][2];
function rot_cos_angle(m) = (rot_trace(m)-1)/2;

function rotation_part(m) = [take3(m[0]),take3(m[1]),take3(m[2])];
function translation_part(m) = [m[0][3],m[1][3],m[2][3]];
function transpose_3(m) = [[m[0][0],m[1][0],m[2][0]],[m[0][1],m[1][1],m[2][1]],[m[0][2],m[1][2],m[2][2]]];
function transpose_4(m) = [[m[0][0],m[1][0],m[2][0],m[3][0]],
                           [m[0][1],m[1][1],m[2][1],m[3][1]],
                           [m[0][2],m[1][2],m[2][2],m[3][2]],
                           [m[0][3],m[1][3],m[2][3],m[3][3]]]; 
function invert_rt(m) = construct_Rt(transpose_3(rotation_part(m)), -(transpose_3(rotation_part(m)) * translation_part(m)));
function construct_Rt(R,t) = [concat(R[0],t[0]),concat(R[1],t[1]),concat(R[2],t[2]),[0,0,0,1]];

// Hadamard product of n-dimensional arrays
function hadamard(a,b) = !(len(a)>0) ? a*b : [ for(i = [0:len(a)-1]) hadamard(a[i],b[i]) ];

function rodrigues_so3_exp(w, A, B) = [
[1.0 - B*(w[1]*w[1] + w[2]*w[2]), B*(w[0]*w[1]) - A*w[2],          B*(w[0]*w[2]) + A*w[1]],
[B*(w[0]*w[1]) + A*w[2],          1.0 - B*(w[0]*w[0] + w[2]*w[2]), B*(w[1]*w[2]) - A*w[0]],
[B*(w[0]*w[2]) - A*w[1],          B*(w[1]*w[2]) + A*w[0],          1.0 - B*(w[0]*w[0] + w[1]*w[1])]
];

function so3_exp(w) = so3_exp_rad(w/180*PI);
function so3_exp_rad(w) =
combine_so3_exp(w,
	w*w < 1e-8 
	? so3_exp_1(w*w)
	: w*w < 1e-6
	  ? so3_exp_2(w*w)
	  : so3_exp_3(w*w));

function combine_so3_exp(w,AB) = rodrigues_so3_exp(w,AB[0],AB[1]);

// Taylor series expansions close to 0
function so3_exp_1(theta_sq) = [
	1 - 1/6*theta_sq, 
	0.5
];

function so3_exp_2(theta_sq) = [
	1.0 - theta_sq * (1.0 - theta_sq/20) / 6,
	0.5 - 0.25/6 * theta_sq
];

function so3_exp_3_0(theta_deg, inv_theta) = [
	sin(theta_deg) * inv_theta,
	(1 - cos(theta_deg)) * (inv_theta * inv_theta)
];

function so3_exp_3(theta_sq) = so3_exp_3_0(sqrt(theta_sq)*180/PI, 1/sqrt(theta_sq));


function rot_axis_part(m) = [m[2][1] - m[1][2], m[0][2] - m[2][0], m[1][0] - m[0][1]]*0.5;

function so3_ln(m) = 180/PI*so3_ln_rad(m);
function so3_ln_rad(m) = so3_ln_0(m,
	cos_angle = rot_cos_angle(m),
	preliminary_result = rot_axis_part(m));

function so3_ln_0(m, cos_angle, preliminary_result) = 
so3_ln_1(m, cos_angle, preliminary_result, 
	sin_angle_abs = sqrt(preliminary_result*preliminary_result));

function so3_ln_1(m, cos_angle, preliminary_result, sin_angle_abs) = 
	cos_angle > sqrt(1/2)
	? sin_angle_abs > 0
	  ? preliminary_result * asin(sin_angle_abs)*PI/180 / sin_angle_abs
	  : preliminary_result
	: cos_angle > -sqrt(1/2)
	  ? preliminary_result * acos(cos_angle)*PI/180 / sin_angle_abs
	  : so3_get_symmetric_part_rotation(
	      preliminary_result,
	      m,
	      angle = PI - asin(sin_angle_abs)*PI/180,
	      d0 = m[0][0] - cos_angle,
	      d1 = m[1][1] - cos_angle,
	      d2 = m[2][2] - cos_angle
			);

function so3_get_symmetric_part_rotation(preliminary_result, m, angle, d0, d1, d2) =
so3_get_symmetric_part_rotation_0(preliminary_result,angle,so3_largest_column(m, d0, d1, d2));

function so3_get_symmetric_part_rotation_0(preliminary_result, angle, c_max) =
	angle * unit(c_max * preliminary_result < 0 ? -c_max : c_max);

function so3_largest_column(m, d0, d1, d2) =
		d0*d0 > d1*d1 && d0*d0 > d2*d2
		?	[d0, (m[1][0]+m[0][1])/2, (m[0][2]+m[2][0])/2]
		: d1*d1 > d2*d2
		  ? [(m[1][0]+m[0][1])/2, d1, (m[2][1]+m[1][2])/2]
		  : [(m[0][2]+m[2][0])/2, (m[2][1]+m[1][2])/2, d2];
/* [Hidden] */
__so3_test = [12,-125,110];
echo(UNITTEST_so3=norm(__so3_test-so3_ln(so3_exp(__so3_test))) < 1e-8);

function combine_se3_exp(w, ABt) = construct_Rt(rodrigues_so3_exp(w, ABt[0], ABt[1]), ABt[2]);

// [A,B,t]
function se3_exp_1(t,w) = concat(
	so3_exp_1(w*w),
	[t + 0.5 * cross(w,t)]
);

function se3_exp_2(t,w) = se3_exp_2_0(t,w,w*w);
function se3_exp_2_0(t,w,theta_sq) = 
se3_exp_23(
	so3_exp_2(theta_sq), 
	C = (1.0 - theta_sq/20) / 6,
	t=t,w=w);

function se3_exp_3(t,w) = se3_exp_3_0(t,w,sqrt(w*w)*180/PI,1/sqrt(w*w));

function se3_exp_3_0(t,w,theta_deg,inv_theta) = 
se3_exp_23(
	so3_exp_3_0(theta_deg = theta_deg, inv_theta = inv_theta),
	C = (1 - sin(theta_deg) * inv_theta) * (inv_theta * inv_theta),
	t=t,w=w);

function se3_exp_23(AB,C,t,w) = 
[AB[0], AB[1], t + AB[1] * cross(w,t) + C * cross(w,cross(w,t)) ];

function se3_exp(mu) = se3_exp_0(t=take3(mu),w=tail3(mu)/180*PI);

function se3_exp_0(t,w) =
combine_se3_exp(w,
// Evaluate by Taylor expansion when near 0
	w*w < 1e-8 
	? se3_exp_1(t,w)
	: w*w < 1e-6
	  ? se3_exp_2(t,w)
	  : se3_exp_3(t,w)
);

function se3_ln(m) = se3_ln_to_deg(se3_ln_rad(m));
function se3_ln_to_deg(v) = concat(take3(v),tail3(v)*180/PI);

function se3_ln_rad(m) = se3_ln_0(m, 
	rot = so3_ln_rad(rotation_part(m)));
function se3_ln_0(m,rot) = se3_ln_1(m,rot,
	theta = sqrt(rot*rot));
function se3_ln_1(m,rot,theta) = se3_ln_2(m,rot,theta,
	shtot = theta > 0.00001 ? sin(theta/2*180/PI)/theta : 0.5,
	halfrotator = so3_exp_rad(rot * -.5));
function se3_ln_2(m,rot,theta,shtot,halfrotator) =
concat( (halfrotator * translation_part(m) - 
	(theta > 0.001 
	? rot * ((translation_part(m) * rot) * (1-2*shtot) / (rot*rot))
	: rot * ((translation_part(m) * rot)/24)
	)) / (2 * shtot), rot);

__se3_test = [20,-40,60,-80,100,-120];
echo(UNITTEST_se3=norm(__se3_test-se3_ln(se3_exp(__se3_test))) < 1e-8);

// List helpers

/*!
  Flattens a list one level:

  flatten([[0,1],[2,3]]) => [0,1,2,3]
*/
function flatten(list) = [ for (i = list, v = i) v ];


/*!
  Creates a list from a range:

  range([0:2:6]) => [0,2,4,6]
*/
function range(r) = [ for(x=r) x ];

/*!
  Reverses a list:

  reverse([1,2,3]) => [3,2,1]
*/
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

/*!
  Extracts a subarray from index begin (inclusive) to end (exclusive)
  FIXME: Change name to use list instead of array?

  subarray([1,2,3,4], 1, 2) => [2,3]
*/
function subarray(list,begin=0,end=-1) = [
    let(end = end < 0 ? len(list) : end)
      for (i = [begin : 1 : end-1])
        list[i]
];

/*!
  Returns a copy of a list with the element at index i set to x

  set([1,2,3,4], 2, 5) => [1,2,5,4]
*/
function set(list, i, x) = [for (i_=[0:len(list)-1]) i == i_ ? x : list[i_]];

/*!
  Remove element from the list by index.
  remove([4,3,2,1],1) => [4,2,1]
*/
function remove(list, i) = [for (i_=[0:1:len(list)-2]) list[i_ < i ? i_ : i_ + 1]];


/*!
  Creates a rotation matrix

  xyz = euler angles = rz * ry * rx
  axis = rotation_axis * rotation_angle
*/
function rotation(xyz=undef, axis=undef) = 
	xyz != undef && axis != undef ? undef :
	xyz == undef  ? se3_exp([0,0,0,axis[0],axis[1],axis[2]]) :
	len(xyz) == undef ? rotation(axis=[0,0,xyz]) :
	(len(xyz) >= 3 ? rotation(axis=[0,0,xyz[2]]) : identity4()) *
	(len(xyz) >= 2 ? rotation(axis=[0,xyz[1],0]) : identity4()) *
	(len(xyz) >= 1 ? rotation(axis=[xyz[0],0,0]) : identity4());

/*!
  Creates a scaling matrix
*/
function scaling(v) = [
	[v[0],0,0,0],
	[0,v[1],0,0],
	[0,0,v[2],0],
	[0,0,0,1],
];

/*!
  Creates a translation matrix
*/
function translation(v) = [
	[1,0,0,v[0]],
	[0,1,0,v[1]],
	[0,0,1,v[2]],
	[0,0,0,1],
];

// Convert between cartesian and homogenous coordinates
function project(x) = subarray(x,end=len(x)-1) / x[len(x)-1];

function transform(m, list) = [for (p=list) project(m * vec4(p))];
function to_3d(list) = [ for(v = list) vec3(v) ];

// Skin a set of profiles with a polyhedral mesh
module skin(profiles, loop=false /* unimplemented */) {
	P = max_len(profiles);
	N = len(profiles);

	profiles = [ 
		for (p = profiles)
			for (pp = augment_profile(to_3d(p),P))
				pp
	];

	function quad(i,P,o) = [[o+i, o+i+P, o+i%P+P+1], [o+i, o+i%P+P+1, o+i%P+1]];

	function profile_triangles(tindex) = [
		for (index = [0:P-1]) 
			let (qs = quad(index+1, P, P*(tindex-1)-1)) 
				for (q = qs) q
	];

    triangles = [ 
		for(index = [1:N-1])
        	for(t = profile_triangles(index)) 
				t
	];
	
	start_cap = [range([0:P-1])];
	end_cap   = [range([P*N-1 : -1 : P*(N-1)])];

	polyhedron(convexity=2, points=profiles, faces=concat(start_cap, triangles, end_cap));
}

// Augments the profile with steiner points making the total number of vertices n 
function augment_profile(profile, n) = 
	subdivide(profile,insert_extra_vertices_0([profile_lengths(profile),dup(0,len(profile))],n-len(profile))[1]);

function subdivide(profile,subdivisions) = let (N=len(profile)) [
	for (i = [0:N-1])
		let(n = len(subdivisions)>0 ? subdivisions[i] : subdivisions)
			for (p = interpolate(profile[i],profile[(i+1)%N],n+1))
				p
];

function interpolate(a,b,subdivisions) = [
	for (index = [0:subdivisions-1])
		let(t = index/subdivisions)
			a*(1-t)+b*t
];

function distribute_extra_vertex(lengths_count,ma_=-1) = ma_<0 ? distribute_extra_vertex(lengths_count, max_element(lengths_count[0])) :
	concat([set(lengths_count[0],ma_,lengths_count[0][ma_] * (lengths_count[1][ma_]+1) / (lengths_count[1][ma_]+2))], [increment(lengths_count[1],max_element(lengths_count[0]),1)]);

function insert_extra_vertices_0(lengths_count,n_extra) = n_extra <= 0 ? lengths_count : 
	insert_extra_vertices_0(distribute_extra_vertex(lengths_count),n_extra-1);

// Find the index of the maximum element of arr
function max_element(arr,ma_,ma_i_=-1,i_=0) = i_ >= len(arr) ? ma_i_ :
	i_ == 0 || arr[i_] > ma_ ? max_element(arr,arr[i_],i_,i_+1) : max_element(arr,ma_,ma_i_,i_+1);

function max_len(arr) = max([for (i=arr) len(i)]);

function increment(arr,i,x=1) = set(arr,i,arr[i]+x);

function profile_lengths(profile) = [ 
	for (i = [0:len(profile)-1])
		profile_segment_length(profile,i)
];

function profile_segment_length(profile,i) = norm(profile[(i+1)%len(profile)] - profile[i]);

// Generates an array with n copies of value (default 0)
function dup(value=0,n) = [for (i = [1:n]) value];


// radial scaling function for tapered lead-in and lead-out
function lilo_taper(x,N,tapered_fraction) = 
    min( min( 1, (1.0/tapered_fraction)*(x/N) ), (1/tapered_fraction)*(1-x/N) )
;

// helical thread with higbee cut at start and end
// to be attached to a cylindrical surface with matching $fn
module straight_thread(section_profile, pitch = 4, turns = 3, r=10, higbee_arc=45, fn=120)
{
	$fn = fn;
	steps = turns*$fn;
	thing =  [ for (i=[0:steps])
		transform(
			rotation([0, 0, 360*i/$fn - 90])*
			translation([0, r, pitch*i/$fn])*
			rotation([90,0,0])*
			rotation([0,90,0])*
			scaling([0.01+0.99*
			lilo_taper(i/turns,steps/turns,(higbee_arc/360)/turns),1,1]),
			section_profile
			)
		];
	skin(thing);
}

// demo: straight_thread(section_profile=demo_thread_profile());
function demo_thread_profile() = [
    [0,0],
    [1.5,1],
    [1.5,1],
    [0,3],
    [-1,3],
    [-1,0]    
];


// PCO-1881 soda bottle cap thread (estimated from bottle thread dims)
function bottle_pco1881_nut_thread_major()   = 27.8; 
function bottle_pco1881_nut_thread_pitch()   = 2.7;
function bottle_pco1881_nut_thread_height()  = 1.15;
function bottle_pco1881_nut_thread_profile() = [
    [0,0],
    [-bottle_pco1881_nut_thread_height(),0.32],
    [-bottle_pco1881_nut_thread_height(),1.12],
    [0,1.42]
];

// PCO-1881 soda bottle neck thread
function bottle_pco1881_neck_clear_dia()      = 21.74;
function bottle_pco1881_neck_thread_dia()     = 24.94;
function bottle_pco1881_neck_thread_pitch()   = 2.7;
function bottle_pco1881_neck_thread_height()  = 1.15;
function bottle_pco1881_neck_thread_profile() = [
    [0,0],
    [0,1.42],
    [bottle_pco1881_neck_thread_height(),1.22],
	[bottle_pco1881_neck_thread_height(),0.22] 
];




/* This script is auto-generated - do not edit
   :License: 3-clause BSD. See LICENSE. */

THREAD_TABLE = [
["PCO-1810-ext", [3.18, 12.055, 24.51, [[0, -1.13], [0, 1.13], [1.66, 0.5258], [1.66, -0.5258]]]],
["PCO-1810-int", [3.18, -14.045, 27.69, [[0, 1.0423], [0, -1.0423], [1.38, -0.54], [1.38, 0.54]]]],
["PCO-1881-ext", [2.7, 11.52381, 24.2, [[0, -0.987894698], [0, 0.987894698], [2.17619, 0.604173686], [2.17619, -0.195826314]]]],
["PCO-1881-int", [2.7, -14.406, 27.66, [[0, 1.212894698], [0, -0.762894698], [1.656, -0.470897218], [1.656, 0.610159990]]]],
];


/*
threadlib
+++++++++

Create threads easily.

:Author: Adrian Schlatter and contributors
:Date: 2023-04-02
:License: 3-Clause BSD. See LICENSE.
*/

function __THREADLIB_VERSION() = 0.5;


function thread_specs(designator, table=THREAD_TABLE) =
    /* Returns thread specs of thread-type 'designator' as a vector of
       [pitch, Rrotation, Dsupport, section_profile] */
      
    // first lookup designator in table inside a let() statement:
    let (specs = table[search([designator], table, num_returns_per_match=1,
                              index_col_num=0)[0]][1])
        // verify that we found something and return it:
        assert(!is_undef(specs), str("Designator: '", designator, "' not found")) specs;

module thread(designator, turns, higbee_arc=20, fn=120, table=THREAD_TABLE)
{
    specs = thread_specs(designator, table=table);
    P = specs[0]; Rrotation = specs[1]; section_profile = specs[3];
    straight_thread(
        section_profile=section_profile,
        higbee_arc=higbee_arc,
        r=Rrotation,
        turns=turns,
        fn=fn,
        pitch=P);
}

module bolt(designator, turns, higbee_arc=20, fn=120, table=THREAD_TABLE) {
    union() {
        specs = thread_specs(str(designator, "-ext"), table=table);
        P = specs[0]; Dsupport = specs[2];
        H = (turns + 1) * P;
        thread(str(designator, "-ext"), turns=turns, higbee_arc=higbee_arc, fn=fn, table=table);
        translate([0, 0, -P / 2])
            cylinder(h=H, d=Dsupport, $fn=fn);
    };
};

module neck_with_thread(){

    difference(){
            union(){
                if (neck_thread=="PCO-1881") {
                    cylinder(h = neck_height, d1 = 24.5, d2 = 24.2, center = false);
                };
                if (neck_thread=="PCO-1810") {
                cylinder(h = neck_height, d = 24.5, center = false);
                };
                 translate([0,0,neck_height])bolt(neck_thread, turns=3, higbee_arc=30);
        }
        translate([0, 0, -0.1])cylinder(h = neck_height+12, d = 24.5-wall_thickness*2, center = false);
        }
}

union(){
    if (body_cone_height < 1) {
        translate([0,0,body_cylinder_height+1])neck_with_thread();
    } else {
        translate([0,0,height])neck_with_thread();
    }

    difference() {
        cylinder(h = body_cylinder_height, d = diameter, center = false);
        translate([0, 0, wall_thickness])cylinder(h = body_cylinder_height, d = diameter-wall_thickness*2, center = false);
    }

    // Cone
    translate([0, 0, body_cylinder_height]) {

  difference() {
    cylinder(h=body_cone_height, d1=diameter, d2=24.5);
    cylinder(h=body_cone_height, d1=diameter-wall_thickness*2, d2=24.5-wall_thickness*2);
    translate([0, 0, body_cone_height-0.1])cylinder(h=0.2, d=24.52-wall_thickness*2);   
  }

    }
}