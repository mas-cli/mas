//
// Region+ISO.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

private import Foundation

typealias Region = String

private extension Region {
	var appStoreRegion: Self {
		switch self { // swiftlint:disable switch_case_on_newline
		case "AD": "ES" // Andorra                                      > Spain
		case "AQ": "NO" // Antarctica                                   > Norway
		case "AS": "US" // American Samoa                               > United States
		case "AW": "NL" // Aruba                                        > Netherlands
		case "AX": "FI" // Åland Islands                                > Finland
		case "BD": "IN" // Bangladesh                                   > India
		case "BI": "KE" // Burundi                                      > Kenya
		case "BL": "FR" // St. Barthélemy                               > France
		case "BQ": "NL" // Bonaire, Sint Eustatius and Saba             > Netherlands
		case "BV": "NO" // Bouvet Island                                > Norway
		case "CC": "AU" // Cocos (Keeling) Islands                      > Australia
		case "CF": "FR" // Central African Republic                     > France
		case "CK": "NZ" // Cook Islands                                 > New Zealand
		case "CU": "US" // Cuba                                         > United States
		case "CW": "NL" // Curaçao                                      > Netherlands
		case "CX": "AU" // Christmas Island                             > Australia
		case "DJ": "FR" // Djibouti                                     > France
		case "EH": "MA" // Western Sahara                               > Morocco
		case "ER": "KE" // Eritrea                                      > Kenya
		case "ET": "KE" // Ethiopia                                     > Kenya
		case "FK": "GB" // Falkland Islands                             > United Kingdom
		case "FO": "DK" // Faroe Islands                                > Denmark
		case "GF": "FR" // French Guiana                                > France
		case "GG": "GB" // Guernsey                                     > United Kingdom
		case "GI": "GB" // Gibraltar                                    > United Kingdom
		case "GL": "DK" // Greenland                                    > Denmark
		case "GN": "FR" // Guinea                                       > France
		case "GP": "FR" // Guadeloupe                                   > France
		case "GQ": "FR" // Equatorial Guinea                            > France
		case "GS": "GB" // South Georgia and the South Sandwich Islands > United Kingdom
		case "GU": "US" // Guam                                         > United States
		case "HM": "AU" // Heard Island and McDonald Islands            > Australia
		case "HT": "US" // Haiti                                        > United States
		case "IC": "ES" // Canary Islands                               > Spain
		case "IM": "GB" // Isle of Man                                  > United Kingdom
		case "IO": "GB" // British Indian Ocean Territory               > United Kingdom
		case "IR": "TR" // Iran                                         > Türkiye
		case "JE": "GB" // Jersey                                       > United Kingdom
		case "KI": "AU" // Kiribati                                     > Australia
		case "KM": "FR" // Comoros                                      > France
		case "KP": "CN" // Korea, Democratic People's Republic of       > China
		case "LI": "CH" // Liechtenstein                                > Switzerland
		case "LS": "ZA" // Lesotho                                      > South Africa
		case "MC": "FR" // Monaco                                       > France
		case "MF": "FR" // St. Martin                                   > France
		case "MH": "US" // Marshall Islands                             > United States
		case "MP": "US" // Northern Mariana Islands                     > United States
		case "MQ": "FR" // Martinique                                   > France
		case "NC": "FR" // New Caledonia                                > France
		case "NF": "AU" // Norfolk Island                               > Australia
		case "NU": "NZ" // Niue                                         > New Zealand
		case "PF": "FR" // French Polynesia                             > France
		case "PM": "FR" // St. Pierre and Miquelon                      > France
		case "PN": "NZ" // Pitcairn Islands                             > New Zealand
		case "PR": "US" // Puerto Rico                                  > United States
		case "PS": "IL" // Palestine                                    > Israel
		case "RE": "FR" // Réunion                                      > France
		case "SD": "EG" // Sudan                                        > Egypt
		case "SH": "GB" // St. Helena, Ascension and Tristan da Cunha   > United Kingdom
		case "SJ": "NO" // Svalbard and Jan Mayen                       > Norway
		case "SM": "IT" // San Marino                                   > Italy
		case "SO": "KE" // Somalia                                      > Kenya
		case "SS": "KE" // South Sudan                                  > Kenya
		case "SX": "NL" // Sint Maarten                                 > Netherlands
		case "SY": "TR" // Syria                                        > Türkiye
		case "TF": "FR" // French Southern Territories                  > France
		case "TG": "FR" // Togo                                         > France
		case "TK": "NZ" // Tokelau                                      > New Zealand
		case "TL": "ID" // Timor-Leste                                  > Indonesia
		case "TV": "AU" // Tuvalu                                       > Australia
		case "UM": "US" // United States Minor Outlying Islands         > United States
		case "VA": "IT" // Vatican City State                           > Italy
		case "VI": "US" // Virgin Islands of the United States          > United States
		case "WF": "FR" // Wallis and Futuna                            > France
		case "WS": "AU" // Samoa                                        > Australia
		case "YT": "FR" // Mayotte                                      > France
		default: self // swiftlint:enable switch_case_on_newline
		}
	}
}

var appStoreRegion: Region {
	macRegion.appStoreRegion
}

var macRegion: Region {
	if #available(macOS 13, *) {
		Locale.current.region?.identifier ?? "US"
	} else {
		Locale.current.regionCode ?? "US"
	}
}
