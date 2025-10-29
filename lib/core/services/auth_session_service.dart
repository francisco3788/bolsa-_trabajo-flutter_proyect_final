import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/profile/domain/usecases/get_current_role.dart';
import '../usecases/usecase.dart';

class AuthSessionService extends GetxService {
  AuthSessionService({
    required SupabaseClient supabaseClient,
    required GetCurrentUser getCurrentUser,
    required GetCurrentRole getCurrentRole,
  })  : _supabaseClient = supabaseClient,
        _getCurrentUser = getCurrentUser,
        _getCurrentRole = getCurrentRole;

  final SupabaseClient _supabaseClient;
  final GetCurrentUser _getCurrentUser;
  final GetCurrentRole _getCurrentRole;

  final Rxn<UserEntity> _user = Rxn<UserEntity>();
  final RxBool _ready = false.obs;
  final RxnString _role = RxnString();
  final RxBool _roleReady = false.obs;

  StreamSubscription<AuthState>? _authSubscription;
  Worker? _routeWorker;
  Worker? _roleWorker;
  Worker? _roleReadyWorker;
  Timer? _chooseRoleTimer;
  bool _initialized = false;
  bool _routerSynced = false;
  Set<String> _publicRoutes = <String>{};
  late String _unauthenticatedRoute;
  String? _authenticatedRoute;
  String Function(UserEntity user, String? role)? _authenticatedRouteResolver;

  UserEntity? get user => _user.value;
  bool get isAuthenticated => _user.value != null;
  bool get isReady => _ready.value;
  String? get role => _role.value;
  bool get isRoleReady => _roleReady.value;

  Stream<UserEntity?> get userStream => _user.stream;
  Stream<bool> get readyStream => _ready.stream;
  Stream<String?> get roleStream => _role.stream;
  Stream<bool> get roleReadyStream => _roleReady.stream;

  void setRole(String? role) {
    _role.value = role;
    _roleReady.value = true;
    if (_routerSynced) {
      _handleRouteChange();
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadCurrentUser();
    await _loadRole();
    _listenToAuthChanges();
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  Future<void> refreshRole() async {
    await _loadRole();
  }

  Future<void> waitForRoleResolution() async {
    if (_roleReady.value) {
      return;
    }
    await _roleReady.stream.firstWhere((ready) => ready == true);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final current = await _getCurrentUser(const NoParams());
      _user.value = current;
    } catch (_) {
      _user.value = null;
    } finally {
      _ready.value = true;
    }
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((
      AuthState data,
    ) async {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.tokenRefreshed:
          await refreshUser();
          await _loadRole();
          break;
        case AuthChangeEvent.signedOut:
          _user.value = null;
          _clearRole();
          break;
        default:
          break;
      }
    });
  }

  void syncWithRouter({
    required Set<String> publicRoutes,
    required String unauthenticatedRoute,
    String? authenticatedRoute,
    String Function(UserEntity user, String? role)? authenticatedRouteResolver,
  }) {
    if (_routerSynced) return;
    _routerSynced = true;

    _publicRoutes = publicRoutes;
    _unauthenticatedRoute = unauthenticatedRoute;
    _authenticatedRoute = authenticatedRoute;
    _authenticatedRouteResolver = authenticatedRouteResolver;

    _routeWorker = ever<UserEntity?>(_user, (_) => _handleRouteChange());
    _roleWorker = ever<String?>(_role, (_) => _handleRouteChange());
    _roleReadyWorker = ever<bool>(_roleReady, (_) => _handleRouteChange());

    _handleRouteChange();
  }

  void _handleRouteChange() {
    if (!isReady || !_routerSynced) return;

    final currentRoute = Get.currentRoute.isEmpty
        ? _unauthenticatedRoute
        : Get.currentRoute;

    if (!isAuthenticated) {
      final isPublicRoute = _publicRoutes.contains(currentRoute);
      if (!isPublicRoute && currentRoute != _unauthenticatedRoute) {
        Get.offAllNamed(_unauthenticatedRoute);
      }
      return;
    }

    if (!_roleReady.value) {
      return;
    }

    final user = _user.value;
    if (user == null) {
      return;
    }

    final targetRoute =
        _authenticatedRouteResolver?.call(user, role) ?? _authenticatedRoute;

    if (targetRoute == null || targetRoute.isEmpty) {
      return;
    }

    final isPublicRoute = _publicRoutes.contains(currentRoute);

    // Si el rol aún no existe y el destino sería choose-role, espera un instante
    // por si el rol se resuelve inmediatamente para evitar un flash de navegación.
    final roleIsMissing = role == null || role!.isEmpty;
    if (roleIsMissing &&
        (isPublicRoute || currentRoute == _unauthenticatedRoute)) {
      _scheduleChooseRoleNavigation(user, currentRoute);
      return;
    }

    _chooseRoleTimer?.cancel();
    if ((isPublicRoute || currentRoute == _unauthenticatedRoute) &&
        currentRoute != targetRoute) {
      Get.offAllNamed(targetRoute);
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _routeWorker?.dispose();
    _roleWorker?.dispose();
    _roleReadyWorker?.dispose();
    _chooseRoleTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadRole() async {
    if (!isAuthenticated) {
      _role.value = null;
      _roleReady.value = true;
      if (_routerSynced) {
        _handleRouteChange();
      }
      return;
    }

    _roleReady.value = false;
    try {
      final currentRole = await _getCurrentRole(const NoParams());
      _role.value = currentRole;
    } catch (_) {
      _role.value = null;
    } finally {
      _roleReady.value = true;
      if (_routerSynced) {
        _handleRouteChange();
      }
    }
  }

  void _clearRole() {
    _role.value = null;
    _roleReady.value = true;
    if (_routerSynced) {
      _handleRouteChange();
    }
  }

  void _scheduleChooseRoleNavigation(UserEntity user, String currentRoute) {
    _chooseRoleTimer?.cancel();
    _chooseRoleTimer = Timer(const Duration(milliseconds: 250), () {
      if (!isAuthenticated || !_roleReady.value) return;

      final targetRoute =
          _authenticatedRouteResolver?.call(user, role) ?? _authenticatedRoute;
      if (targetRoute == null || targetRoute.isEmpty) return;

      final isPublicRoute = _publicRoutes.contains(currentRoute);
      if ((isPublicRoute || currentRoute == _unauthenticatedRoute) &&
          currentRoute != targetRoute) {
        Get.offAllNamed(targetRoute);
      }
    });
  }
}
