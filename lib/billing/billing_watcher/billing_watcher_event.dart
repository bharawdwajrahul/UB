part of 'billing_watcher_bloc.dart';

@freezed
class BillingWatcherEvent with _$BillingWatcherEvent {
  const factory BillingWatcherEvent.watchAllStarted() =
  _WatchAllStarted;
  const factory BillingWatcherEvent.assetsWatched(Either<BillingFailure, List<BillingDetailsList>> failureOrBilling,
      ) = _BillingReceived;
}