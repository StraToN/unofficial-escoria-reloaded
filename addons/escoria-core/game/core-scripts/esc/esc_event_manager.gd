# A manager for running events
extends Node
class_name ESCEventManager


# Return codes handled by events
# * RC_OK: Event run okay
# * RC_CANCEL: Cancel all scheduled and queued events
# * RC_ERROR: Error running a command
# * RC_REPEAT: Repeat the current scope from the beginning
enum {RC_OK, RC_CANCEL, RC_ERROR, RC_REPEAT}


# The currently event running
var running_event: ESCEvent = null

# A queue of events to run
var events_queue: Array = []

# A list of currently scheduled events
var scheduled_events: Array = []


# Handle the events queue and scheduled events
func _process(delta):
	if not self.running_event and events_queue.size() > 0:
		self.running_event = events_queue.pop_front()
		self.running_event.connect("event_finished", self, "_on_event_finished")
		self.running_event.run()
	for event in self.scheduled_events:
		(event as ESCScheduledEvent).timeout -= delta
		if (event as ESCScheduledEvent).timeout <= 0:
			self.scheduled_events.erase(event)
			self.events_queue.append(event)


# Queue a new event to run
func queue_event(event: ESCEvent) -> void:
	events_queue.append(event)
	

# Schedule an event to run after a timeout
func schedule_event(event: ESCEvent, timeout: float) -> void:
	scheduled_events.append(ESCScheduledEvent.new(event, timeout))


# The event finished running
func _on_event_finished(return_code: int) -> void:
	self.running_event.disconnect("event_finished", self, "_on_event_finished")
	self.running_event = null
	match(return_code):
		RC_CANCEL:
			self.scheduled_events = []
			self.events_queue = []
