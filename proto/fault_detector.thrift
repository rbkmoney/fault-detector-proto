include "base.thrift"

namespace java com.rbkmoney.damsel.fault_detector
namespace erlang fault_detector

typedef base.ID ServiceId
typedef base.ID OperationId
typedef i32     Seconds
typedef i64     Milliseconds
typedef i64     OperationsCount
typedef double  FailureRate

/** Ответ сервиса определения ошибок на запрос статистики для сервиса */
struct ServiceStatistics {
    /** ID сервиса */
    1: required ServiceId         service_id
    /** Показатель частоты отказов для данного сервиса от 0 до 1, где 0 - это отсутствие ошибок, а 1 - исключительно сбойные операции */
    2: required FailureRate       failure_rate
    /** Общее количество операций для сервиса */
    3: required OperationsCount   operations_count
    /** Количество операций завершившихся с ошибкой */
    4: required OperationsCount   error_operations_count
    /** Количество операций превысивших ожидаемое время выполнения */
    5: required OperationsCount   overtime_operations_count
    /** Количество операций, которые еще выполняются и превысили ожидаемое время выполнения */
    6: required OperationsCount   success_operations_count
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

union OperationState {
    1: Start        start
    2: Finish       finish
    3: Error        error
}

struct Operation {
    1: required OperationId      operation_id
    2: required OperationState   state
}

/** Конфигурация детектора ошибок для конкретного сервиса */
struct ServiceConfig {
    /** Временной интервал для "скользящего окна" (время в рамках которого будут браться операции для расчета статистики) */
    1: required Milliseconds sliding_window
    /** Ожидаемое время выполнения операции */
    2: required Milliseconds operation_time_limit
    /** Временной интервал для преагрегации операций */
    3: optional Seconds pre_aggregation_size
}

exception ServiceNotFoundException {}

service FaultDetector {
    /** Инициализация параметров сервиса */
    void InitService(1: ServiceId service_id, 2: ServiceConfig service_config)
    /** Получение статистики по сервисам */
    list<ServiceStatistics> GetStatistics(1: list<ServiceId> services)
    /** Регистрация операции сервиса **/
    void RegisterOperation(1: ServiceId service_id, 2: Operation operation, 3: ServiceConfig service_config) throws (1: ServiceNotFoundException ex1)
}
