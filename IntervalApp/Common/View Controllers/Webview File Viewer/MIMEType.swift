//
//  MIMEType.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

public enum MIMEType: String {

    // CAREFUL!!! All new cases must be added to the allValues array

    case html, htm, shtml, css, xml, gif, jpeg, jpg, js, atom, rss, mml, txt, jad, wml, htc, png, tif, tiff, wbmp,
    ico, jng, bmp, svg, svgz, webp, woff, jar, war, ear, json, hqx, doc, pdf, ps, eps, ai, rtf, m3U8, xls, eot,
    ppt, wmlc, kml, kmz, cco, jardiff, jnlp, run, pl, pm, prc, pdb, rar, rpm, sea, swf, sit, tcl, tk, der, pem,
    crt, xpi, xhtml, xspf, zip, bin,exe, dll, deb, dmg, iso, img, msi, msp, msm, docx, xlsx, pptx, mid, midi,
    kar, mp3, ogg, m4A, ra, ts, mp4, mpeg, mpg, mov, webm, flv, m4V, mng, asx, asf, wmv, avi

    public static let allValues = [html, htm, shtml, css, xml, gif, jpeg, jpg, js, atom, rss, mml, txt, jad, wml, htc, png, tif, tiff, wbmp,
                                   ico, jng, bmp, svg, svgz, webp, woff, jar, war, ear, json, hqx, doc, pdf, ps, eps, ai, rtf, m3U8, xls, eot,
                                   ppt, wmlc, kml, kmz, cco, jardiff, jnlp, run, pl, pm, prc, pdb, rar, rpm, sea, swf, sit, tcl, tk, der, pem,
                                   crt, xpi, xhtml, xspf, zip, bin,exe, dll, deb, dmg, iso, img, msi, msp, msm, docx, xlsx, pptx, mid, midi,
                                   kar, mp3, ogg, m4A, ra, ts, mp4, mpeg, mpg, mov, webm, flv, m4V, mng, asx, asf, wmv, avi]

    public var value: String {

        switch self {

        case .atom: return "application/atom+xml"
        case .woff: return "application/font-woff"
        case .jar, .war, .ear:  return "application/java-archive"
        case .js: return "application/javascript"
        case .json: return "application/json"
        case .hqx: return "application/mac-binhex40"
        case .doc: return "application/msword"
        case .bin, .exe, .dll, .deb, .dmg, .iso, .img, .msi, .msp, .msm: return "application/octet-stream"
        case .pdf: return "application/pdf"
        case .ps, .eps, .ai: return "application/postscript"
        case .rss: return "application/rss+xml"
        case .rtf: return "application/rtf"
        case .m3U8: return "application/vnd.apple.mpegurl"
        case .kml: return "application/vnd.google-earth.kml+xml"
        case .kmz: return "application/vnd.google-earth.kmz"
        case .xls: return "application/vnd.ms-excel"
        case .eot: return "application/vnd.ms-fontobject"
        case .ppt: return "application/vnd.ms-powerpoint"
        case .pptx: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .xlsx: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .docx: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .wmlc: return "application/vnd.wap.wmlc"
        case .cco: return "application/x-cocoa"
        case .jardiff: return "application/x-java-archive-diff"
        case .jnlp: return "application/x-java-jnlp-file"
        case .run: return "application/x-makeself"
        case .pl, .pm: return "application/x-perl"
        case .prc, .pdb: return "application/x-pilot"
        case .rar: return "application/x-rar-compressed"
        case .rpm: return "application/x-redhat-package-manager"
        case .sea: return "application/x-sea"
        case .swf: return "application/x-shockwave-flash"
        case .sit: return "application/x-stuffit"
        case .tcl, .tk: return "application/x-tcl"
        case .der, .pem, .crt: return "application/x-x509-ca-cert"
        case .xpi: return "application/x-xpinstall"
        case .xhtml: return "application/xhtml+xml"
        case .xspf: return "application/xspf+xml"
        case .zip: return "application/zip"
        case .mid, .midi, .kar: return "audio/midi"
        case .mp3: return "audio/mpeg"
        case .ogg: return "audio/ogg"
        case .m4A: return "audio/x-m4a"
        case .ra: return "audio/x-realaudio"
        case .gif: return "image/gif"
        case .jpeg, .jpg: return "image/jpeg"
        case .png: return "image/png"
        case .svg, .svgz: return "image/svg+xml"
        case .tif, .tiff: return "image/tiff"
        case .wbmp: return "image/vnd.wap.wbmp"
        case .webp: return "image/webp"
        case .ico: return "image/x-icon"
        case .jng: return "image/x-jng"
        case .bmp: return "image/x-ms-bmp"
        case .html, .shtml, .htm: return "text/html"
        case .css: return "text/css"
        case .mml: return "text/mathml"
        case .txt: return "text/plain"
        case .jad: return "text/vnd.sun.j2me.app-descriptor"
        case .wml: return "text/vnd.wap.wml"
        case .htc: return "text/x-component"
        case .xml: return "text/xml"
        case .ts: return "video/mp2t"
        case .mp4: return "video/mp4"
        case .mpeg, .mpg: return "video/mpeg"
        case .mov: return "video/quicktime"
        case .webm: return "video/webm"
        case .flv: return "video/x-flv"
        case .m4V: return "video/x-m4v"
        case .mng: return "video/x-mng"
        case .asx, .asf: return "video/x-ms-asf"
        case .wmv: return "video/x-ms-wmv"
        case .avi: return "video/x-msvideo"

        }
    }
}
