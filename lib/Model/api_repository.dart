import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_repository.g.dart';

@RestApi(baseUrl: 'https://owner-api.teslamotors.com')
abstract class ApiRepository {
  factory ApiRepository(Dio dio, {String baseUrl}) = _ApiRepository;

  factory ApiRepository.withOptions(
      {String? baseUrl, BaseOptions? dioOptions}) {
    final dio = Dio(dioOptions);
    return _ApiRepository(dio, baseUrl: baseUrl);
  }

  @GET("/api/1/products")
  Future<ProductResponse> getProducts(
    @Header("Authorization") String authorization,
  );

  @GET("/api/1/energy_sites/{energySiteId}/site_info")
  Future<SiteInfoResponse> getSiteInfo(
    @Path("energySiteId") int energySiteId,
    @Header("Authorization") String authorization,
  );

  @POST("/api/1/energy_sites/{energySiteId}/backup")
  Future<void> setBatteryReserve(
    @Path("energySiteId") int energySiteId,
    @Header("Authorization") String authorization,
    @Field("backup_reserve_percent") int backupReservePercent,
  );
//様子見
  /*@POST("/api/1/energy_sites/{energySiteId}/operation")
  Future<void> setRealMode(
    @Path("enegySiteId") int enegySiteId,
    @Header("Authorization") String authorization,
    @Field("mode") String defaultRealMode,
  );*/
}

class ProductResponse {
  final List<ProductResponseItem> response;
  final int count;

  ProductResponse({
    required this.response,
    required this.count,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      response: (json['response'] as List<dynamic>)
          .map((item) => ProductResponseItem.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }
}

class ProductResponseItem {
  final int energySiteId;
  final String resourceType;
  final String id;
  final String assetSiteId;
  final int solarPower;
  final String solarType;
  final bool syncGridAlertEnabled;
  final bool breakerAlertEnabled;
  final ProductComponents components;

  ProductResponseItem({
    required this.energySiteId,
    required this.resourceType,
    required this.id,
    required this.assetSiteId,
    required this.solarPower,
    required this.solarType,
    required this.syncGridAlertEnabled,
    required this.breakerAlertEnabled,
    required this.components,
  });

  factory ProductResponseItem.fromJson(Map<String, dynamic> json) {
    return ProductResponseItem(
      energySiteId: json['energy_site_id'] as int? ?? 0,
      resourceType: json['resource_type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      assetSiteId: json['asset_site_id'] as String? ?? '',
      solarPower: json['solar_power'] as int? ?? 0,
      solarType: json['solar_type'] as String? ?? '',
      syncGridAlertEnabled: json['sync_grid_alert_enabled'] as bool,
      breakerAlertEnabled: json['breaker_alert_enabled'] as bool,
      components: ProductComponents.fromJson(
          json['components'] as Map<String, dynamic>),
    );
  }
}

class ProductComponents {
  final bool battery;
  final bool solar;
  final String solarType;
  final bool grid;
  final bool loadMeter;
  final String marketType;

  ProductComponents({
    required this.battery,
    required this.solar,
    required this.solarType,
    required this.grid,
    required this.loadMeter,
    required this.marketType,
  });

  factory ProductComponents.fromJson(Map<String, dynamic> json) {
    return ProductComponents(
      battery: json['battery'] as bool,
      solar: json['solar'] as bool,
      solarType: json['solar_type'] as String? ?? '',
      grid: json['grid'] as bool,
      loadMeter: json['load_meter'] as bool,
      marketType: json['market_type'] as String? ?? '',
    );
  }
}

class SiteInfoResponse {
  final SiteInfoData response;

  SiteInfoResponse({
    required this.response,
  });

  factory SiteInfoResponse.fromJson(Map<String, dynamic> json) {
    return SiteInfoResponse(
      response: SiteInfoData.fromJson(json['response'] as Map<String, dynamic>),
    );
  }
}

class SiteInfoData {
  final String defaultRealMode;
  final int backupReservePercent;

  SiteInfoData(
      {required this.defaultRealMode, required this.backupReservePercent});

  factory SiteInfoData.fromJson(Map<String, dynamic> json) {
    return SiteInfoData(
      defaultRealMode: json['default_real_mode'] as String? ?? '',
      backupReservePercent: json['backup_reserve_percent'] as int? ?? 0,
    );
  }
}
