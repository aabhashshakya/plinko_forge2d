///Created by Aabhash Shakya on 12/3/24
import 'package:flutter/material.dart';

class CategoryBits{
  CategoryBits._();
  //used to identify this fixture and help to avoid/accept them in collision
  //Typically, you start from the least significant bit and assign each object type a power of 2.
  static int ball = 0x0001; // 	0001 //1
  static int obstacles = 0x0002; // 0010 //2
  static int moneyMultipliers = 0x0004; //0100 //4
  static int wall = 0x0008; //1000 //8
  static int guideRails = 0x0010; //0001 0000 //16



  // When you use powers of 2, bitwise operations (|, &) become highly efficient for combining or checking categories:
  //
  // Combining Categories:
  // The bitwise OR (|) operation is used to INCLUDE multiple categories in the collision mask.
  // Example: 0x0001 | 0x0004 → 0001 | 0100 = 0101
  // This allows an object to interact with Category 1 and Category 4.
  //
  // Checking Categories:
  // The bitwise AND (&) operation is used to test whether a collision involves a specific category.
  // Example: (0x0002 & 0x0004) → 0010 & 0100 = 0000 (no collision)
  // This ensures precise filtering without needing complex logic.

  // Analogy: Light Switches
  // Think of each bit as a light switch:
  //
  // If a bit is ON (1), the category is active in collisions.
  // If a bit is OFF (0), the category is inactive.
  // By using powers of 2, each switch controls only one light without interference.


}