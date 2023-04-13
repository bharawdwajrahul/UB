import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../domain/billingDetails.dart';
import '../domain/billingFacade.dart';
import '../domain/billingFailure.dart';


part 'billing_watcher_bloc.freezed.dart';
part 'billing_watcher_event.dart';
part 'billing_watcher_state.dart';

@injectable
class BillingWatcherBloc extends Bloc<BillingWatcherEvent, BillingWatcherState> {
  final IBillingFacade billingWatcherRepository;

  BillingWatcherBloc(this.billingWatcherRepository)
      : super(const BillingWatcherState.initial());

  StreamSubscription<Either<BillingFailure, List<BillingDetailsList>>>?
  billingStreamSubscription;

  @override
  Stream<BillingWatcherState> mapEventToState(
      BillingWatcherEvent event,
      ) async* {
    yield* event.map(
      watchAllStarted: (e) async* {
        yield const BillingWatcherState.loadInProgress();
        await billingStreamSubscription?.cancel();
        billingStreamSubscription =
            billingWatcherRepository.billingWatch().listen(
                  (failureOrBookings) =>
                  add(BillingWatcherEvent.assetsWatched(failureOrBookings)),
            );
        print('inside watcher billing bloc--');
      },
      assetsWatched: (e) async* {
        yield e.failureOrBilling.fold(
              (f) => BillingWatcherState.loadFailure(f),
              (assets) => BillingWatcherState.loadSuccess(assets),
        );
        print('watcher billing failure-----');

      },
    );
  }

}
