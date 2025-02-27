/* Authors: Matt Liberty */
/*
 * Copyright (c) 2020, The Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the University nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/polygon/polygon.hpp>
#include <boost/serialization/array.hpp>
#include <boost/serialization/list.hpp>
#include <boost/serialization/map.hpp>
#include <boost/serialization/set.hpp>
#include <boost/serialization/split_member.hpp>
#include <boost/serialization/unique_ptr.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/weak_ptr.hpp>

#include "db/obj/frShape.h"
#include "db/obj/frNet.h"
#include "db/tech/frConstraint.h"
#include "global.h"
#include "db/gcObj/gcNet.h"
#include "db/gcObj/gcPin.h"
#include "db/gcObj/gcShape.h"
#include "db/drObj/drMarker.h"
#include "db/drObj/drNet.h"
#include "db/drObj/drPin.h"
#include "db/obj/frAccess.h"
#include "db/obj/frBlockage.h"
#include "db/obj/frBoundary.h"
#include "db/obj/frGCellPattern.h"
#include "db/obj/frGuide.h"
#include "db/obj/frInst.h"
#include "db/obj/frInstBlockage.h"
#include "db/obj/frMarker.h"
#include "db/obj/frNode.h"
#include "db/obj/frPin.h"
#include "db/obj/frRPin.h"
#include "db/obj/frVia.h"
#include "db/obj/frTrackPattern.h"
#include "db/infra/frBox.h"
#include "odb/geom.h"
#include "odb/dbTypes.h"
namespace gtl = boost::polygon;
namespace bg = boost::geometry;

namespace boost::serialization {

// Enable serialization of a std::tuple using recursive templates.
// For some reason boost serialize seems to leave out this std class.
template <uint N>
struct TupleSerializer
{
  template <class Archive, typename... Types>
  static void serialize(Archive& ar,
                        std::tuple<Types...>& t,
                        const unsigned int version)
  {
    (ar) & std::get<N - 1>(t);
    TupleSerializer<N - 1>::serialize(ar, t, version);
  }
};

template <>
struct TupleSerializer<0>
{
  template <class Archive, typename... Types>
  static void serialize(Archive& /* ar */,
                        std::tuple<Types...>& /* t */,
                        const unsigned int /* version */)
  {
  }
};

template <class Archive, typename... Types>
void serialize(Archive& ar, std::tuple<Types...>& t, const unsigned int version)
{
  TupleSerializer<sizeof...(Types)>::serialize(ar, t, version);
}

// Sadly boost polygon lacks serializers so here are some home grown ones.
template <class Archive>
void serialize(Archive& ar,
               gtl::point_data<fr::frCoord>& point,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord x = 0;
    fr::frCoord y = 0;
    (ar) & x;
    (ar) & y;
    point.x(x);
    point.y(y);
  } else {
    fr::frCoord x = point.x();
    fr::frCoord y = point.y();
    (ar) & x;
    (ar) & y;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::interval_data<fr::frCoord>& interval,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord low = 0;
    fr::frCoord high = 0;
    (ar) & low;
    (ar) & high;
    interval.low(low);
    interval.high(high);
  } else {
    auto low = interval.low();
    auto high = interval.high();
    (ar) & low;
    (ar) & high;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::segment_data<fr::frCoord>& segment,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    gtl::point_data<fr::frCoord> low;
    gtl::point_data<fr::frCoord> high;
    (ar) & low;
    (ar) & high;
    segment.low(low);
    segment.high(high);
  } else {
    gtl::point_data<fr::frCoord> low = segment.low();
    gtl::point_data<fr::frCoord> high = segment.high();
    (ar) & low;
    (ar) & high;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::rectangle_data<fr::frCoord>& rect,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    gtl::interval_data<fr::frCoord> h;
    gtl::interval_data<fr::frCoord> v;
    (ar) & h;
    (ar) & v;
    rect.set(gtl::HORIZONTAL, h);
    rect.set(gtl::VERTICAL, v);
  } else {
    auto h = rect.get(gtl::HORIZONTAL);
    auto v = rect.get(gtl::VERTICAL);
    (ar) & h;
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::polygon_90_data<fr::frCoord>& polygon,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    std::vector<fr::frCoord> coordinates;
    (ar) & coordinates;
    polygon.set_compact(coordinates.begin(), coordinates.end());
  } else {
    std::vector<fr::frCoord> coordinates(polygon.begin_compact(),
                                         polygon.end_compact());
    (ar) & coordinates;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::polygon_90_with_holes_data<fr::frCoord>& polygon,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    gtl::polygon_90_data<fr::frCoord> outside;
    (ar) & outside;
    polygon.set(outside.begin(), outside.end());

    std::list<gtl::polygon_90_data<fr::frCoord>> holes;
    (ar) & holes;
    polygon.set_holes(holes.begin(), holes.end());
  } else {
    gtl::polygon_90_data<fr::frCoord> outside;
    outside.set(polygon.begin(), polygon.end());
    (ar) & outside;
    std::list<gtl::polygon_90_data<fr::frCoord>> holes(polygon.begin_holes(),
                                                       polygon.end_holes());
    (ar) & holes;
  }
}

template <class Archive>
void serialize(Archive& ar,
               gtl::polygon_90_set_data<fr::frCoord>& polygon_set,
               const unsigned int version)
{
  std::vector<gtl::polygon_90_with_holes_data<fr::frCoord>> polygons;
  if (fr::is_loading(ar)) {
    (ar) & polygons;
    polygon_set.insert(polygons.begin(), polygons.end());
  } else {
    polygon_set.get_polygons(polygons);
    (ar) & polygons;
  }
}

// Sadly boost geometry lacks serializers so here are some home grown ones.
template <class Archive>
void serialize(Archive& ar, fr::point_t& point, const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord x = 0;
    fr::frCoord y = 0;
    (ar) & x;
    (ar) & y;
    point.x(x);
    point.y(y);
  } else {
    fr::frCoord x = point.x();
    fr::frCoord y = point.y();
    (ar) & x;
    (ar) & y;
  }
}

template <class Archive>
void serialize(Archive& ar, fr::segment_t& segment, const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord xl = 0;
    fr::frCoord xh = 0;
    fr::frCoord yl = 0;
    fr::frCoord yh = 0;
    (ar) & xl;
    (ar) & xh;
    (ar) & yl;
    (ar) & yh;
    bg::set<0, 0>(segment, xl);
    bg::set<0, 1>(segment, xh);
    bg::set<1, 0>(segment, yl);
    bg::set<1, 1>(segment, yh);
  } else {
    fr::frCoord xl = bg::get<0, 0>(segment);
    fr::frCoord xh = bg::get<0, 1>(segment);
    fr::frCoord yl = bg::get<1, 0>(segment);
    fr::frCoord yh = bg::get<1, 1>(segment);
    (ar) & xl;
    (ar) & xh;
    (ar) & yl;
    (ar) & yh;
  }
}

// odb classes
template <class Archive>
void serialize(Archive& ar,
               odb::Rect& r,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord xlo = 0, ylo = 0, xhi = 0, yhi = 0;
    (ar) & xlo;
    (ar) & ylo;
    (ar) & xhi;
    (ar) & yhi;
    r.reset(xlo, ylo, xhi, yhi);
  } else {
    fr::frCoord xlo, ylo, xhi, yhi;
    xlo = r.xMin();
    ylo = r.yMin();
    xhi = r.xMax();
    yhi = r.yMax();
    (ar) & xlo;
    (ar) & ylo;
    (ar) & xhi;
    (ar) & yhi;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::Point& p,
               const unsigned int version)
{
  if (fr::is_loading(ar)) {
    fr::frCoord x = 0, y = 0;
    (ar) & x;
    (ar) & y;
    p.set(x, y);
  } else {
    fr::frCoord x, y;
    x = p.x();
    y = p.y();
    (ar) & x;
    (ar) & y;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbSigType& type,
               const unsigned int version)
{
  odb::dbSigType::Value v = odb::dbSigType::SIGNAL;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbSigType(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbIoType& type,
               const unsigned int version)
{
  odb::dbIoType::Value v = odb::dbIoType::INOUT;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbIoType(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbTechLayerType& type,
               const unsigned int version)
{
  odb::dbTechLayerType::Value v = odb::dbTechLayerType::NONE;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbTechLayerType(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbMasterType& type,
               const unsigned int version)
{
  odb::dbMasterType::Value v = odb::dbMasterType::NONE;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbMasterType(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbTechLayerDir& type,
               const unsigned int version)
{
  odb::dbTechLayerDir::Value v = odb::dbTechLayerDir::NONE;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbTechLayerDir(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbOrientType& type,
               const unsigned int version)
{
  odb::dbOrientType::Value v = odb::dbOrientType::R0;
  if (fr::is_loading(ar)) {
    (ar) & v;
    type = odb::dbOrientType(v);
  } else {
    v = type.getValue();
    (ar) & v;
  }
}

template <class Archive>
void serialize(Archive& ar,
               odb::dbTransform& transform,
               const unsigned int version)
{
  odb::dbOrientType type = odb::dbOrientType::R0;
  odb::Point offset;
  if (fr::is_loading(ar)) {
    (ar) & type;
    (ar) & offset;
    transform.setOrient(type);
    transform.setOffset(offset);
  } else {
    type = transform.getOrient();
    offset = transform.getOffset();
    (ar) & type;
    (ar) & offset;
  }
}


}  // namespace boost::serialization

namespace fr {

template <class Archive>
void register_types(Archive& ar)
{
  // The serialization library needs to be told about these classes
  // as we often only encounter them through their base classes.
  // More details here
  // https://www.boost.org/doc/libs/1_76_0/libs/serialization/doc/serialization.html#derivedpointers

  ar.template register_type<frRect>();
  ar.template register_type<frPathSeg>();
  ar.template register_type<frPatchWire>();
  ar.template register_type<frPolygon>();
  ar.template register_type<frInstTerm>();
  ar.template register_type<frBTerm>();
  ar.template register_type<frMTerm>();
  ar.template register_type<frMaster>();
  ar.template register_type<frNet>();

  ar.template register_type<frLef58CutClassConstraint>();
  ar.template register_type<frRecheckConstraint>();
  ar.template register_type<frShortConstraint>();
  ar.template register_type<frNonSufficientMetalConstraint>();
  ar.template register_type<frOffGridConstraint>();
  ar.template register_type<frMinEnclosedAreaConstraint>();
  ar.template register_type<frLef58MinStepConstraint>();
  ar.template register_type<frMinStepConstraint>();
  ar.template register_type<frMinimumcutConstraint>();
  ar.template register_type<frAreaConstraint>();
  ar.template register_type<frMinWidthConstraint>();
  ar.template register_type<
      frLef58SpacingEndOfLineWithinEncloseCutConstraint>();
  ar.template register_type<frLef58SpacingEndOfLineWithinEndToEndConstraint>();
  ar.template register_type<
      frLef58SpacingEndOfLineWithinParallelEdgeConstraint>();
  ar.template register_type<
      frLef58SpacingEndOfLineWithinMaxMinLengthConstraint>();
  ar.template register_type<frLef58SpacingEndOfLineWithinConstraint>();
  ar.template register_type<frLef58SpacingEndOfLineConstraint>();
  ar.template register_type<frLef58CornerSpacingSpacingConstraint>();
  ar.template register_type<frSpacingConstraint>();
  ar.template register_type<frSpacingSamenetConstraint>();
  ar.template register_type<frSpacingTableInfluenceConstraint>();
  ar.template register_type<frSpacingEndOfLineConstraint>();
  ar.template register_type<frSpacingTablePrlConstraint>();
  ar.template register_type<frSpacingTableTwConstraint>();
  ar.template register_type<frSpacingTableConstraint>();
  ar.template register_type<frLef58SpacingTableConstraint>();
  ar.template register_type<frCutSpacingConstraint>();
  ar.template register_type<frLef58CutSpacingConstraint>();
  ar.template register_type<frLef58CornerSpacingConstraint>();
  ar.template register_type<frLef58CornerSpacingSpacingConstraint>();
  ar.template register_type<frLef58CornerSpacingSpacing1DConstraint>();
  ar.template register_type<frLef58CornerSpacingSpacing2DConstraint>();
  ar.template register_type<frLef58RectOnlyConstraint>();
  ar.template register_type<frLef58RightWayOnGridOnlyConstraint>();

  ar.template register_type<drPathSeg>();
  ar.template register_type<drVia>();
  ar.template register_type<drPatchWire>();

  ar.template register_type<drMazeMarker>();
  ar.template register_type<drNet>();
  ar.template register_type<drPin>();

  ar.template register_type<gcNet>();
  ar.template register_type<gcPin>();
  ar.template register_type<gcSegment>();
  ar.template register_type<gcPolygon>();
  ar.template register_type<gcRect>();
  ar.template register_type<frAccessPoint>();
  ar.template register_type<frPinAccess>();
  ar.template register_type<frBlockage>();
  ar.template register_type<frBoundary>();
  ar.template register_type<frGCellPattern>();
  ar.template register_type<frGuide>();
  ar.template register_type<frInst>();
  ar.template register_type<frInstBlockage>();
  ar.template register_type<frMarker>();
  ar.template register_type<frNode>();
  ar.template register_type<frBPin>();
  ar.template register_type<frMPin>();
  ar.template register_type<frRPin>();
  ar.template register_type<frVia>();
  ar.template register_type<frTrackPattern>();
  ar.template register_type<frBox3D>();
}

template <class Archive>
void serialize_globals(Archive& ar)
{
  (ar) & GUIDE_FILE;
  (ar) & OUTGUIDE_FILE;
  (ar) & DBPROCESSNODE;
  (ar) & OUT_MAZE_FILE;
  (ar) & DRC_RPT_FILE;
  (ar) & CMAP_FILE;
  (ar) & OR_SEED;
  (ar) & OR_K;
  (ar) & MAX_THREADS;
  (ar) & BATCHSIZE;
  (ar) & BATCHSIZETA;
  (ar) & MTSAFEDIST;
  (ar) & DRCSAFEDIST;
  (ar) & VERBOSE;
  (ar) & BOTTOM_ROUTING_LAYER_NAME;
  (ar) & TOP_ROUTING_LAYER_NAME;
  (ar) & BOTTOM_ROUTING_LAYER;
  (ar) & TOP_ROUTING_LAYER;
  (ar) & ALLOW_PIN_AS_FEEDTHROUGH;
  (ar) & USENONPREFTRACKS;
  (ar) & USEMINSPACING_OBS;
  (ar) & ENABLE_BOUNDARY_MAR_FIX;
  (ar) & ENABLE_VIA_GEN;
  (ar) & VIAINPIN_BOTTOMLAYER_NAME;
  (ar) & VIAINPIN_TOPLAYER_NAME;
  (ar) & VIAINPIN_BOTTOMLAYERNUM;
  (ar) & VIAINPIN_TOPLAYERNUM;
  (ar) & VIA_ACCESS_LAYERNUM;
  (ar) & MINNUMACCESSPOINT_MACROCELLPIN;
  (ar) & MINNUMACCESSPOINT_STDCELLPIN;
  (ar) & ACCESS_PATTERN_END_ITERATION_NUM;
  (ar) & END_ITERATION;
  (ar) & NDR_NETS_RIPUP_HARDINESS;
  (ar) & CLOCK_NETS_TRUNK_RIPUP_HARDINESS;
  (ar) & CLOCK_NETS_LEAF_RIPUP_HARDINESS;
  (ar) & AUTO_TAPER_NDR_NETS;
  (ar) & TAPERBOX_RADIUS;
  (ar) & NDR_NETS_ABS_PRIORITY;
  (ar) & CLOCK_NETS_ABS_PRIORITY;
  (ar) & TAVIACOST;
  (ar) & TAPINCOST;
  (ar) & TAALIGNCOST;
  (ar) & TADRCCOST;
  (ar) & TASHAPEBLOATWIDTH;
  (ar) & VIACOST;
  (ar) & GRIDCOST;
  (ar) & FIXEDSHAPECOST;
  (ar) & ROUTESHAPECOST;
  (ar) & MARKERCOST;
  (ar) & MARKERBLOATWIDTH;
  (ar) & BLOCKCOST;
  (ar) & GUIDECOST;
  (ar) & MARKERDECAY;
  (ar) & SHAPEBLOATWIDTH;
  (ar) & MISALIGNMENTCOST;
  (ar) & HISTCOST;
  (ar) & CONGCOST;
}

using InputArchive = boost::archive::binary_iarchive;
using OutputArchive = boost::archive::binary_oarchive;

}  // namespace fr
