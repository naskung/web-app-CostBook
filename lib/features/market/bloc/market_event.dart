part of 'market_bloc.dart';

abstract class MarketEvent {}

class MarketOpened extends MarketEvent {}

class MarketCheckRequested extends MarketEvent {}
