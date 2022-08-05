// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//


import { Strings } from '../OpenZeppelin/utils/Strings.sol';

contract BokkyPooBahsDateTimeLookup {
    using Strings for uint256;


    function monthStringLong (uint month) public pure returns (string memory) {
        if (month == 1) return "January";
        if (month == 2) return "February";
        if (month == 3) return "March";
        if (month == 4) return "April";
        if (month == 5) return "May";
        if (month == 6) return "June";
        if (month == 7) return "July";
        if (month == 8) return "August";
        if (month == 9) return "September";
        if (month == 10) return "October";
        if (month == 11) return "November";
        if (month == 12) return "December";
        return "";
    }

    function monthStringShort (uint month) public pure returns (string memory) {
        if (month == 1) return "Jan";
        if (month == 2) return "Feb";
        if (month == 3) return "Mar";
        if (month == 4) return "Apr";
        if (month == 5) return "May";
        if (month == 6) return "Jun";
        if (month == 7) return "Jul";
        if (month == 8) return "Aug";
        if (month == 9) return "Sep";
        if (month == 10) return "Oct";
        if (month == 11) return "Nov";
        if (month == 12) return "Dec";
        return "";
    }

    function dayOfMonthString (uint dayOfMonth) public pure returns (string memory) {
        if (dayOfMonth == 1) return "1st";
        if (dayOfMonth == 2) return "2nd";
        if (dayOfMonth == 3) return "3rd";
        if (dayOfMonth == 21) return "21st";
        if (dayOfMonth == 22) return "22nd";
        if (dayOfMonth == 23) return "23rd";
        if (dayOfMonth == 31) return "31st";
        if (dayOfMonth < 31 && dayOfMonth > 0 ) {
            return string(abi.encodePacked(dayOfMonth.toString(), 'th'));
        }

    }


}
