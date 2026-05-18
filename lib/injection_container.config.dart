// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/config/base_url_provider.dart' as _i755;
import 'core/network/network_info.dart' as _i75;
import 'core/util/input_converter.dart' as _i702;
import 'features/account/data/datasources/account_remote_datasource.dart'
    as _i971;
import 'features/account/data/repositories/account_repository_impl.dart'
    as _i545;
import 'features/account/domain/repositories/account_repository.dart' as _i510;
import 'features/account/domain/usecases/get_fault_report_history.dart'
    as _i941;
import 'features/account/domain/usecases/get_rental_history.dart' as _i927;
import 'features/account/domain/usecases/report_fault.dart' as _i488;
import 'features/account/presentation/bloc/fault_history_bloc.dart' as _i250;
import 'features/account/presentation/bloc/rental_history_bloc.dart' as _i355;
import 'features/account/presentation/bloc/report_fault_bloc.dart' as _i546;
import 'features/auth/data/datasources/auth_local_datasource.dart' as _i1043;
import 'features/auth/data/datasources/auth_remote_datasource.dart' as _i588;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/get_current_user.dart' as _i191;
import 'features/auth/domain/usecases/login_user.dart' as _i1073;
import 'features/auth/domain/usecases/logout_user.dart' as _i657;
import 'features/auth/domain/usecases/register_user.dart' as _i14;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/map/data/datasources/map_local_datasource.dart' as _i297;
import 'features/map/data/datasources/map_remote_datasource.dart' as _i272;
import 'features/map/data/repositories/map_repository_impl.dart' as _i1035;
import 'features/map/domain/repositories/map_repository.dart' as _i914;
import 'features/map/domain/usecases/get_nearby_bikes.dart' as _i990;
import 'features/map/domain/usecases/get_stations.dart' as _i284;
import 'features/map/domain/usecases/invalidate_map_cache.dart' as _i136;
import 'features/map/presentation/bloc/map_bloc.dart' as _i236;
import 'features/number_trivia/data/datasources/number_trivia_local_datasource.dart'
    as _i1020;
import 'features/number_trivia/data/datasources/number_trivia_remote_datasource.dart'
    as _i724;
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart'
    as _i36;
import 'features/number_trivia/domain/contracts/number_trivia_repository_contract.dart'
    as _i90;
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart'
    as _i285;
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart'
    as _i722;
import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart'
    as _i65;
import 'features/options/data/datasources/options_local_datasource.dart'
    as _i690;
import 'features/options/data/repositories/options_repository_impl.dart'
    as _i459;
import 'features/options/domain/repositories/options_repository.dart' as _i190;
import 'features/options/domain/usecases/get_api_options.dart' as _i181;
import 'features/options/domain/usecases/save_api_options.dart' as _i954;
import 'features/options/presentation/bloc/options_bloc.dart' as _i630;
import 'features/rental/data/datasources/rental_remote_datasource.dart'
    as _i316;
import 'features/rental/data/repositories/rental_repository_impl.dart' as _i888;
import 'features/rental/domain/repositories/rental_repository.dart' as _i133;
import 'features/rental/domain/usecases/cancel_reservation.dart' as _i135;
import 'features/rental/domain/usecases/check_rental_eligibility.dart' as _i441;
import 'features/rental/domain/usecases/create_reservation.dart' as _i660;
import 'features/rental/domain/usecases/end_rental.dart' as _i24;
import 'features/rental/domain/usecases/get_active_rental.dart' as _i366;
import 'features/rental/domain/usecases/get_active_reservation.dart' as _i192;
import 'features/rental/domain/usecases/pause_rental.dart' as _i671;
import 'features/rental/domain/usecases/resume_rental.dart' as _i201;
import 'features/rental/domain/usecases/start_rental.dart' as _i360;
import 'features/rental/presentation/bloc/rental_bloc.dart' as _i56;
import 'features/rental/presentation/bloc/reservation_bloc.dart' as _i586;
import 'features/wallet/data/datasources/wallet_remote_datasource.dart' as _i54;
import 'features/wallet/data/repositories/wallet_repository_impl.dart' as _i104;
import 'features/wallet/domain/repositories/wallet_repository.dart' as _i193;
import 'features/wallet/domain/usecases/add_payment_method.dart' as _i618;
import 'features/wallet/domain/usecases/get_payment_methods.dart' as _i178;
import 'features/wallet/domain/usecases/get_transactions.dart' as _i478;
import 'features/wallet/domain/usecases/get_wallet.dart' as _i54;
import 'features/wallet/domain/usecases/top_up_wallet.dart' as _i622;
import 'features/wallet/presentation/bloc/wallet_bloc.dart' as _i63;
import 'injection_container.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i702.InputConverter>(() => _i702.InputConverter());
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i161.InternetConnection>(
      () => registerModule.internetConection,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i724.NumberTriviaRemoteDataSource>(
      () => _i724.NumberTriviaRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i1020.NumberTriviaLocalDataSource>(
      () => _i1020.NumberTriviaLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i297.MapLocalDataSource>(
      () => _i297.MapLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i75.NetworkInfo>(
      () => _i75.NetworkInfoImpl(gh<_i161.InternetConnection>()),
    );
    gh.lazySingleton<_i690.OptionsLocalDataSource>(
      () => _i690.OptionsLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i1043.AuthLocalDataSource>(
      () => _i1043.AuthLocalDataSourceImpl(
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i190.OptionsRepository>(
      () => _i459.OptionsRepositoryImpl(
        localDataSource: gh<_i690.OptionsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i181.GetApiOptions>(
      () => _i181.GetApiOptions(gh<_i190.OptionsRepository>()),
    );
    gh.lazySingleton<_i954.SaveApiOptions>(
      () => _i954.SaveApiOptions(gh<_i190.OptionsRepository>()),
    );
    gh.lazySingleton<_i755.BaseUrlProvider>(
      () => _i755.BaseUrlProvider(gh<_i190.OptionsRepository>()),
    );
    gh.lazySingleton<_i630.OptionsBloc>(
      () => _i630.OptionsBloc(
        getApiOptions: gh<_i181.GetApiOptions>(),
        saveApiOptions: gh<_i954.SaveApiOptions>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
      () => _i588.AuthRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i90.NumberTriviaRepository>(
      () => _i36.NumberTriviaRepositoryImpl(
        remoteDataSource: gh<_i724.NumberTriviaRemoteDataSource>(),
        localDataSource: gh<_i1020.NumberTriviaLocalDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i316.RentalRemoteDataSource>(
      () => _i316.RentalRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i285.GetConcreteNumberTrivia>(
      () => _i285.GetConcreteNumberTrivia(gh<_i90.NumberTriviaRepository>()),
    );
    gh.lazySingleton<_i722.GetRandomNumberTrivia>(
      () => _i722.GetRandomNumberTrivia(gh<_i90.NumberTriviaRepository>()),
    );
    gh.lazySingleton<_i54.WalletRemoteDataSource>(
      () => _i54.WalletRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i971.AccountRemoteDataSource>(
      () => _i971.AccountRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i272.MapRemoteDataSource>(
      () => _i272.MapRemoteDataSourceImpl(
        dio: gh<_i361.Dio>(),
        baseUrlProvider: gh<_i755.BaseUrlProvider>(),
      ),
    );
    gh.lazySingleton<_i133.RentalRepository>(
      () => _i888.RentalRepositoryImpl(
        remoteDataSource: gh<_i316.RentalRemoteDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i510.AccountRepository>(
      () => _i545.AccountRepositoryImpl(
        remoteDataSource: gh<_i971.AccountRemoteDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i135.CancelReservation>(
      () => _i135.CancelReservation(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i441.CheckRentalEligibility>(
      () => _i441.CheckRentalEligibility(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i660.CreateReservation>(
      () => _i660.CreateReservation(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i24.EndRental>(
      () => _i24.EndRental(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i366.GetActiveRental>(
      () => _i366.GetActiveRental(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i192.GetActiveReservation>(
      () => _i192.GetActiveReservation(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i671.PauseRental>(
      () => _i671.PauseRental(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i201.ResumeRental>(
      () => _i201.ResumeRental(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i360.StartRental>(
      () => _i360.StartRental(gh<_i133.RentalRepository>()),
    );
    gh.lazySingleton<_i914.MapRepository>(
      () => _i1035.MapRepositoryImpl(
        remoteDataSource: gh<_i272.MapRemoteDataSource>(),
        localDataSource: gh<_i297.MapLocalDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        remoteDataSource: gh<_i588.AuthRemoteDataSource>(),
        localDataSource: gh<_i1043.AuthLocalDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.factory<_i65.NumberTriviaBloc>(
      () => _i65.NumberTriviaBloc(
        getConcreteNumberTrivia: gh<_i285.GetConcreteNumberTrivia>(),
        getRandomNumberTrivia: gh<_i722.GetRandomNumberTrivia>(),
        inputConverter: gh<_i702.InputConverter>(),
      ),
    );
    gh.lazySingleton<_i193.WalletRepository>(
      () => _i104.WalletRepositoryImpl(
        remoteDataSource: gh<_i54.WalletRemoteDataSource>(),
        networkInfo: gh<_i75.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i586.ReservationBloc>(
      () => _i586.ReservationBloc(
        createReservation: gh<_i660.CreateReservation>(),
        cancelReservation: gh<_i135.CancelReservation>(),
        getActiveReservation: gh<_i192.GetActiveReservation>(),
      ),
    );
    gh.lazySingleton<_i990.GetNearbyBikes>(
      () => _i990.GetNearbyBikes(gh<_i914.MapRepository>()),
    );
    gh.lazySingleton<_i284.GetStations>(
      () => _i284.GetStations(gh<_i914.MapRepository>()),
    );
    gh.lazySingleton<_i136.InvalidateMapCache>(
      () => _i136.InvalidateMapCache(gh<_i914.MapRepository>()),
    );
    gh.lazySingleton<_i191.GetCurrentUser>(
      () => _i191.GetCurrentUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i1073.LoginUser>(
      () => _i1073.LoginUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i657.LogoutUser>(
      () => _i657.LogoutUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i14.RegisterUser>(
      () => _i14.RegisterUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i941.GetFaultReportHistory>(
      () => _i941.GetFaultReportHistory(gh<_i510.AccountRepository>()),
    );
    gh.lazySingleton<_i927.GetRentalHistory>(
      () => _i927.GetRentalHistory(gh<_i510.AccountRepository>()),
    );
    gh.lazySingleton<_i488.ReportFault>(
      () => _i488.ReportFault(gh<_i510.AccountRepository>()),
    );
    gh.lazySingleton<_i236.MapBloc>(
      () => _i236.MapBloc(
        getNearbyBikes: gh<_i990.GetNearbyBikes>(),
        getStations: gh<_i284.GetStations>(),
        invalidateMapCache: gh<_i136.InvalidateMapCache>(),
      ),
    );
    gh.factory<_i355.RentalHistoryBloc>(
      () => _i355.RentalHistoryBloc(
        getRentalHistory: gh<_i927.GetRentalHistory>(),
      ),
    );
    gh.lazySingleton<_i56.RentalBloc>(
      () => _i56.RentalBloc(
        checkRentalEligibility: gh<_i441.CheckRentalEligibility>(),
        startRental: gh<_i360.StartRental>(),
        pauseRental: gh<_i671.PauseRental>(),
        resumeRental: gh<_i201.ResumeRental>(),
        endRental: gh<_i24.EndRental>(),
        getActiveRental: gh<_i366.GetActiveRental>(),
      ),
    );
    gh.lazySingleton<_i618.AddPaymentMethod>(
      () => _i618.AddPaymentMethod(gh<_i193.WalletRepository>()),
    );
    gh.lazySingleton<_i178.GetPaymentMethods>(
      () => _i178.GetPaymentMethods(gh<_i193.WalletRepository>()),
    );
    gh.lazySingleton<_i478.GetTransactions>(
      () => _i478.GetTransactions(gh<_i193.WalletRepository>()),
    );
    gh.lazySingleton<_i54.GetWallet>(
      () => _i54.GetWallet(gh<_i193.WalletRepository>()),
    );
    gh.lazySingleton<_i622.TopUpWallet>(
      () => _i622.TopUpWallet(gh<_i193.WalletRepository>()),
    );
    gh.lazySingleton<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        loginUser: gh<_i1073.LoginUser>(),
        registerUser: gh<_i14.RegisterUser>(),
        logoutUser: gh<_i657.LogoutUser>(),
        getCurrentUser: gh<_i191.GetCurrentUser>(),
      ),
    );
    gh.factory<_i546.ReportFaultBloc>(
      () => _i546.ReportFaultBloc(reportFault: gh<_i488.ReportFault>()),
    );
    gh.factory<_i250.FaultHistoryBloc>(
      () => _i250.FaultHistoryBloc(
        getFaultReportHistory: gh<_i941.GetFaultReportHistory>(),
      ),
    );
    gh.lazySingleton<_i63.WalletBloc>(
      () => _i63.WalletBloc(
        getWallet: gh<_i54.GetWallet>(),
        getTransactions: gh<_i478.GetTransactions>(),
        topUpWallet: gh<_i622.TopUpWallet>(),
        getPaymentMethods: gh<_i178.GetPaymentMethods>(),
        addPaymentMethod: gh<_i618.AddPaymentMethod>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i809.RegisterModule {}
