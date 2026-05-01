//
//  Helpers.swift
//  SongLingo
//
//  Created by Austin Robertson on 4/30/26.
//

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
