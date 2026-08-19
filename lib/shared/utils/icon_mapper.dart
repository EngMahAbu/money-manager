import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

// Map icon string names to TablerIcons IconData
IconData getTablerIcon(String? iconName) {
  if (iconName == null) return TablerIcons.category;
  
  switch (iconName) {
    case 'shopping-cart': return TablerIcons.shopping_cart;
    case 'briefcase': return TablerIcons.briefcase;
    case 'home': return TablerIcons.home;
    case 'bolt': return TablerIcons.bolt;
    case 'car': return TablerIcons.car;
    case 'tools-kitchen-2': return TablerIcons.tools_kitchen_2;
    case 'movie': return TablerIcons.movie;
    case 'heartbeat': return TablerIcons.heartbeat;
    case 'shopping-bag': return TablerIcons.shopping_bag;
    case 'repeat': return TablerIcons.repeat;
    case 'plane': return TablerIcons.plane;
    case 'book': return TablerIcons.book;
    case 'dots': return TablerIcons.dots;
    case 'gift': return TablerIcons.gift;
    case 'device-laptop': return TablerIcons.device_laptop;
    case 'trending-up': return TablerIcons.trending_up;
    case 'medical_cross': return TablerIcons.medical_cross;
    case 'wallet': return TablerIcons.wallet;
    case 'building-bank': return TablerIcons.building_bank;
    case 'credit-card': return TablerIcons.credit_card;
    case 'arrow-right': return TablerIcons.arrow_right;
    case 'category': return TablerIcons.category;
    case 'tag': return TablerIcons.tag;
    default: return TablerIcons.category;
  }
}
