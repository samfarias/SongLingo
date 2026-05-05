//
//  Helpers.swift
//  SongLingo
//
//  Created by Austin Robertson on 4/30/26.
//

import SwiftUI

func calculateMasteryLvl(numActivitiesCompleted: Int) -> Int {
    if (numActivitiesCompleted <= 5) {
        return 0;
    } else if (numActivitiesCompleted > 5 && numActivitiesCompleted <= 15) {
        return 1;
    } else if (numActivitiesCompleted > 15 && numActivitiesCompleted <= 45) {
        return 2;
    } else {
        return 3;
    }
}

func getMasteryLvlFillColor(numActivitiesCompleted: Int) -> LinearGradient {
    if (numActivitiesCompleted <= 5) {
        return Constants.yellow;
    } else if (numActivitiesCompleted > 5 && numActivitiesCompleted <= 15) {
        return Constants.lavender;
    } else if (numActivitiesCompleted > 15 && numActivitiesCompleted <= 45) {
        return Constants.blue;
    } else {
        return Constants.green;
    }
}
