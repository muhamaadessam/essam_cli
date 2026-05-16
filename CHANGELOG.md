## 1.0.1+1

- Replace `Either<Failure, T>` with `Result<T>` in repository, use case, and data source templates
- Simplify `DataSource` implementation by utilizing `DioHelper.getData` with the new `fromJson` parameter
- Refine regex patterns and formatting in `CubitGenerator` and `DataSourceGenerator`
- Update device streaming configuration with Galaxy A32 options

## 1.0.1

- Add DioConfig for flexible API configuration
- Add TwafokConfig for centralized app settings
- Add CacheHelper integration
- Improve theme management
- Add API shortcuts (get, post, put, patch, delete)

## 1.0.0

- Initial release
- Basic widgets and utilities
- Theme support