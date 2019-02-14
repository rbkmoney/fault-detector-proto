include "base.thrift"

namespace java com.rbkmoney.damsel.fault_detector
namespace erlang fault_detector

typedef base.ID ServiceId
 typedef base.ID OperationId
typedef i64     Milliseconds
typedef double  FailureRate
typedef i16     TimeoutDelta

/** Ответ сервиса определения ошибок на запрос статистики для сервиса */
struct ServiceStatistics {

    /** ID сервиса */
    1: required ServiceId   service_id
    /** Показатель частоты отказов для данного сервиса от 0 до 1, где 0 - это отсутствие ошибок,
    * а 1 - исключительно сбойные операции
    */
    2: required FailureRate failure_rate

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
    /** Время жизни операции в рамках сервиса (в рамках данного времени будет рассчитано среднее время выполнения операции) */
    1: required Milliseconds operation_lifetime
    /** Временной интервал для "скользящего окна" (время в рамках которого будут браться операции для расчета статистики) */
    2: required Milliseconds sliding_window
    /**
    * Таймаут дельта. Использвется при определении операций, которые не уложились в планируемое время выполнения.
    * Задается как десятичное число как отображение дельты в процентах. Например, если timeout_delta = 10, а среднее
    * время выполнения 4000мс, то операции превысившие 4400мс будут считаться как сбойные (если не задан
    * hovering_operation_error_delay больший чем 4400)
    */
    3: optional TimeoutDelta timeout_delta
    /** Время, после которого операция считается зависшей. Если не задано, то будет равно среднему времени
    * выполнения транзакции + дельта
    */
    4: optional Milliseconds hovering_operation_error_delay
    /** Значение инициализируюзего параметра отказа сервиса (значение от 0 до 1). Если задать, то приведет значение
     * уровня ошибок до определенного уровня путем вставки операций-пустышек. Может понадобиться для опримизации
     * "отзывчивости" сервиса на сбой
     */
    5: optional FailureRate  init_failure_rate
}

exception ServiceNotFoundException {}

service FaultDetector {

    /** Инициализация параметров сервиса */
    void InitService(1: ServiceId service_id, 2: ServiceConfig service_config)
    /** Получение статистики по сервисам */
    list<ServiceStatistics> GetStatistics(1: list<ServiceId> services)
    /** Регистрация операции сервиса **/
    void RegisterOperation(1: ServiceId service_id, 2: RequestId request_id, 3: Operation operation) throws (1: ServiceNotFoundException ex1)
    /** Сброс/Установка статистики сервиса **/
    void UpdateServiceConfig(1: ServiceId service_id, 2: ServiceConfig service_config) throws (1: ServiceNotFoundException ex1)

}
