/*
 * Copyright (C) 2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4

Canvas {
    id: triangle
    antialiasing: true

    property color color: "#ffffff"
    property int lineWidth: 3
    property bool fill: false

    onLineWidthChanged:requestPaint();
    onFillChanged:requestPaint();

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.clearRect(0,0,triangle.width, triangle.height);
        ctx.strokeStyle = triangle.color;
        ctx.lineWidth = triangle.lineWidth
        ctx.fillStyle = triangle.color
        ctx.globalAlpha = 1.0
        ctx.lineJoin = "round";
        ctx.beginPath();

        ctx.translate(0,  0);
        ctx.lineTo(0, triangle.height);
        ctx.lineTo(triangle.width,  0.5 * triangle.height);
        ctx.lineTo(0,  0);

        if (triangle.fill)
          ctx.fill();
        if (triangle.stroke)
          ctx.stroke();
        ctx.restore();
    }
}
