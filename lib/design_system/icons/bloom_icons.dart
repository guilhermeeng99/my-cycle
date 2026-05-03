import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Bloom icon registry — semantic names mapped to Font Awesome.
///
/// Reference icons through Bloom names so the visual identity changes in
/// one place if the icon set is ever swapped. Defaults to the regular
/// (light-weight outline) FontAwesome family for a calm, journal-like feel
/// that matches the Bloom design language.
abstract final class BloomIcons {
  // Navigation
  static const IconData arrowLeft = FontAwesomeIcons.arrowLeft;
  static const IconData chevronLeft = FontAwesomeIcons.chevronLeft;
  static const IconData chevronRight = FontAwesomeIcons.chevronRight;

  // Primary surfaces
  static const IconData calendar = FontAwesomeIcons.calendarDays;
  static const IconData settings = FontAwesomeIcons.gear;

  // Actions
  static const IconData edit = FontAwesomeIcons.penToSquare;
  static const IconData copy = FontAwesomeIcons.copy;
  static const IconData link = FontAwesomeIcons.link;
  static const IconData signOut = FontAwesomeIcons.rightFromBracket;

  // Status / feedback
  static const IconData clock = FontAwesomeIcons.clock;
  static const IconData warning = FontAwesomeIcons.circleExclamation;
  static const IconData check = FontAwesomeIcons.check;
  static const IconData info = FontAwesomeIcons.circleInfo;

  // Cycle motifs
  static const IconData heart = FontAwesomeIcons.heart;
  static const IconData flow = FontAwesomeIcons.droplet;
  static const IconData sparkle = FontAwesomeIcons.wandMagicSparkles;
  static const IconData moon = FontAwesomeIcons.moon;
  static const IconData sun = FontAwesomeIcons.sun;

  // Settings motifs
  static const IconData globe = FontAwesomeIcons.globe;
  static const IconData appearance = FontAwesomeIcons.circleHalfStroke;
  static const IconData bell = FontAwesomeIcons.bell;
  static const IconData shield = FontAwesomeIcons.shieldHalved;
  static const IconData cycle = FontAwesomeIcons.repeat;
  static const IconData person = FontAwesomeIcons.user;
  static const IconData people = FontAwesomeIcons.userGroup;

  // Bottom nav (filled/regular pairs)
  static const IconData navToday = FontAwesomeIcons.seedling;
  static const IconData navCalendar = FontAwesomeIcons.calendarDays;
  static const IconData navCalendarFilled = FontAwesomeIcons.solidCalendarDays;
  static const IconData navInsights = FontAwesomeIcons.chartSimple;
  static const IconData navSettings = FontAwesomeIcons.gear;
}
