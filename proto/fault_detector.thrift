include "base.thrift"

namespace java com.rbkmoney.damsel.fault_detector
namespace erlang fault_detector

typedef base.ID ServiceId
typedef base.ID RequestId

enum Reliability {
    BAD = 0
    DEGRADED = 10
    GOOD = 20
}

struct Availability {
    1: required ServiceId service_id
    2: required double timeout_rate // сколько запросов вышли за пределы среднего значения времени
    3: required double success_rate // сколько запросово из общего количества завершились успешно
    5: required Reliability reliability // если хотим положиться на рассчёты сервиса
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

union ErrorReason {
    1: Timeout timeout
    2: Unavailable unavailable
}

struct Timeout {}
struct Unavailable {}

struct Error {
    1: required base.Timestamp time_end
    2: required ErrorReason error_reason
}

// Устанавливаем какие-то из значений для disable/enable сервиса, полезная ручка
struct ServiceConfig {
    1: required Type type
    2: required double value // Значение от 0 до 1
}

enum Type {
    TIMEOUT_RATE
    SUCCESS_RATE
    ALL
}

service FaultDetector {

    /**
     * Проверка доступности сервисов
     **/
    list<Availability> CheckAvailability(1: list<ServiceId> services)

    /**
     * Регистрация процесса операции
     **/
    void RegisterOperation(1: ServiceId service_id, 2: RequestId request_id, 3: Operation operation)

    /**
     * Сброс/Установка статистики сервиса.
     * Может потенциально пригодиться для более умных сервисов, которые вкурсе "проблем"
     **/
    void SetServiceStatistics(1: ServiceId service_id, 2: ServiceConfig service_config)

}