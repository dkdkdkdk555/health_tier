part of 'app_database.dart';

class Notifications extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  IntColumn get feedId => integer().nullable()();
  TextColumn get type => text()();
  TextColumn get receivedAt => text()();
  TextColumn get isRead => text().withDefault(const Constant('false'))();
}