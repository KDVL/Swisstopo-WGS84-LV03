
// The MIT License (MIT)
//
// Copyright (c) 2014 Federal Office of Topography swisstopo, Wabern, CH
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//
//  Created by Kevin Do Vale (https://github.com/KDVL/) on 12.11.20.
//  Source: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/topics/survey/sys/refsys/projections.html (see PDFs under "Documentation")
//  Please validate your results with NAVREF on-line service: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/apps/calc/navref.html (difference ~ 1-2m)



import UIKit

class CoordinateConverter: NSObject {

    /**
     * Convert LV03 to WGS84 Return an object that contain lat, long and height
     *
     * @param east
     * @param north
     * @param height
     * @return WGS84
     */
    static func LV03toWGS84( east:Double, north:Double, height:Double) -> WGS84 {
        return WGS84(
            lat: CHtoWGSlat(y: east, x: north),
            lng: CHtoWGSlng(y: east, x: north),
            height: CHtoWGSheight(y: east, x: north, h: height))
    }

    /**
     * Convert LV03 to WGS84 Return an object that contain lat, long and height
     *
     * @param LV03
     * @return WGS84
     */
    static func LV03toWGS84(LV03:LV03) -> WGS84 {
        return LV03toWGS84(east: LV03.east, north: LV03.north, height: LV03.height)
    }

    /**
     * Convert WGS84 to LV03 Return an object that contain east, north, and height
     *
     * @param lat
     * @param lng
     * @param ellHeight
     * @return LV03
     */
    static func WGS84toLV03(lat:Double, lng:Double, ellHeight:Double) -> LV03 {
        // ref double east, ref double north, ref double height
        return LV03(east: WGStoCHy(lat: lat, lng: lng),
                    north: WGStoCHx(lat: lat, lng: lng),
                    height: WGStoCHh(lat: lat, lng: lng, h: ellHeight))
    }

    /**
     * Convert WGS84 to LV03 Return an object that contain east, north, and height
     *
     * @param WGS84
     * @return LV03
     */
    static func WGS84toLV03(WGS84:WGS84) -> LV03 {
        // ref double east, ref double north, ref double height
        return WGS84toLV03(lat: WGS84.lat, lng: WGS84.lng, ellHeight: WGS84.height)
    }


    /// Convert CH y/x/h to WGS height
    private static func CHtoWGSheight(y:Double, x:Double, h:Double) -> Double {
        // Converts military to civil and to unit = 1000km
        // Auxiliary values (% Bern)
        let y_aux = (y - 600000) / 1000000
        let x_aux = (x - 200000) / 1000000

        // Process height
        let resH = (h + 49.55) - (12.60 * y_aux) - (22.64 * x_aux)

        return resH
    }

    /// Convert CH y/x to WGS lat
    private static func CHtoWGSlat(y:Double, x:Double) -> Double {
        // Converts military to civil and to unit = 1000km
        // Auxiliary values (% Bern)
        let y_aux = (y - 600000) / 1000000
        let x_aux = (x - 200000) / 1000000

        // Process lat
        var lat = (16.9023892 + (3.238272 * x_aux))
                - (0.270978 * (y_aux * y_aux))
                - (0.002528 * (x_aux * x_aux))
                - (0.0447 * (y_aux * y_aux) * x_aux)
                - (0.0140 * (x_aux * x_aux * x_aux))

        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lat = (lat * 100) / 36

        return lat
    }

    /// Convert CH y/x to WGS long
    private static func CHtoWGSlng(y:Double, x:Double) -> Double {
        // Converts military to civil and to unit = 1000km
        // Auxiliary values (% Bern)
        let y_aux = (y - 600000) / 1000000
        let x_aux = (x - 200000) / 1000000

        // Process long
        var lng = (2.6779094 + (4.728982 * y_aux)
                + (0.791484 * y_aux * x_aux) + (0.1306 * y_aux * (x_aux * x_aux)))
                - (0.0436 * (y_aux * y_aux * y_aux))

        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lng = (lng * 100) / 36

        return lng
    }

    /// Convert decimal angle (degrees) to sexagesimal angle (seconds)
    private static func DecToSexAngle(dec:Double) -> Double{
        let deg:Int =  Int(floor(dec))
        let min:Int =  Int(floor((dec - Double(deg)) * 60))
        let sec:Double = (((dec - Double(deg)) * 60) - Double(min)) * 60

        return sec + Double(min) * 60.0 + Double(deg) * 3600.0
    }


    /// Convert WGS lat/long (° dec) and height to CH h
    private static func WGStoCHh(lat:Double, lng:Double, h:Double) -> Double {
        // Converts dec degrees to sex seconds
        let lat = DecToSexAngle(dec: lat)
        let lng = DecToSexAngle(dec: lng)

        // Auxiliary values (% Bern)
        let lat_aux = (lat - 169028.66) / 10000
        let lng_aux = (lng - 26782.5) / 10000

        // Process h
        let resH = (h - 49.55) + (2.73 * lng_aux) + (6.94 * lat_aux)

        return resH
    }

    /// Convert WGS lat/long (° dec) to CH x
    private static func WGStoCHx(lat:Double, lng:Double) -> Double {
        // Converts dec degrees to sex seconds
        let lat = DecToSexAngle(dec: lat)
        let lng = DecToSexAngle(dec: lng)

        // Auxiliary values (% Bern)
        let lat_aux = (lat - 169028.66) / 10000
        let lng_aux = (lng - 26782.5) / 10000

        // Process X
        let x = ((200147.07 + (308807.95 * lat_aux)
                + (3745.25 * (lng_aux * lng_aux))
                    + (76.63 * (lat_aux * lat_aux)))
                - (194.56 * (lng_aux * lng_aux) * lat_aux))
                + (119.79 * (lat_aux * lat_aux * lat_aux))

        return x
    }

    /// Convert WGS lat/long (° dec) to CH y
    private static func WGStoCHy(lat:Double, lng:Double) -> Double {
        // Converts dec degrees to sex seconds
        let lat = DecToSexAngle(dec: lat)
        let lng = DecToSexAngle(dec: lng)

        // Auxiliary values (% Bern)
        let lat_aux = (lat - 169028.66) / 10000
        let lng_aux = (lng - 26782.5) / 10000

        // Process Y
        let y = (600072.37 + (211455.93 * lng_aux))
                - (10938.51 * lng_aux * lat_aux)
                - (0.36 * lng_aux * (lat_aux * lat_aux))
                - (44.54 * (lng_aux * lng_aux * lng_aux))

        return y
    }

    private override init() {}
}

struct WGS84 {
    let lat:Double
    let lng:Double
    let height:Double
}


struct LV03 {
    let east:Double
    let north:Double
    let height:Double
}
