include "base.thrift"

namespace java com.rbkmoney.damsel.fault_detector
namespace erlang fault_detector

typedef base.ID ServiceId
typedef base.ID RequestId

/** Ответ сервиса определения ошибок на запрос статистики для сервиса */
struct ServiceStatistics {

    /** ID сервиса */
    1: required ServiceId service_id
    /** Процент ошибок для данного сервиса */
    2: required double failure_rate

}

union Operation {
    1: Start start
    2: Finish finish
    3: Error error
}

struct Start {
    1: required base.Timestamp time_start
}

struct Finish {
    1: required base.Timestamp time_end
}

struct Error {
    1: required base.Timestamp time_end
}

/**
* Конфигурация детектора ошибок для конкретного сервиса
*
* Предполагается, что временные характеристики будут заданы в мс
**/
struct ServiceConfig {
    /** Время жизни операции в рамках сервиса */
    1: required i64 operation_lifetime
    /** Время жизни зависшей операции для сервиса (если не задать, то аналогично обычной операции) */
    2: optional i64 hovering_operation_lifetime
    /** Временной интервал для "скользящего окна" - время в рамках которого будут ьраться транзакции */
    3: optional i64 sliding_window
    /** Время, после которого операция считается зависшей */
    4: optional i64 hovering_operation_error_delay
    /** Значение параметра инициализируюзего параметра откащов сервиса (значение от 0 до 1) */
    5: optional double init_failure_rate
}

service FaultDetector {

    /** Инициализация параметров сервиса */
    void InitService(1: ServiceId service_id, 2: ServiceConfig service_config)
    /** Получение статистики по сервису */
    ServiceStatistics GetStatistics(1: ServiceId service_id)
    /** Регистрация операции сервиса **/
    void RegisterOperation(1: ServiceId service_id, 2: RequestId request_id, 3: Operation operation)
    /** Сброс/Установка статистики сервиса **/
    void UpdateServiceConfig(1: ServiceId service_id, 2: ServiceConfig service_config)

}