Code.require_file "../test_helper.exs", __FILE__

defmodule NeuronProcessTest do

  use ExUnit.Case
	alias Neurlang.Neuron, as: Neuron
	alias Neurlang.NeuronProcess, as: NeuronProcess
	alias Neurlang.Sensor, as: Sensor
	alias Neurlang.SensorProcess, as: SensorProcess
	alias Neurlang.Actuator, as: Actuator
	alias Neurlang.ActuatorProcess, as: ActuatorProcess
	alias Neurlang.Mock.MockNode, as: MockNode
	alias Neurlang.Mock.MockNodeProcess, as: MockNodeProcess
	alias Neurlang.Connector, as: Connector
	alias Neurlang.TestHelper, as: TestHelper

	test "new v2 connected neuron" do

		neuron = Neuron.new(id: make_ref(), bias: bias(10), activation_function: function(:summation, 3))
		neuron = NeuronProcess.start_link(neuron)

		sensor = Sensor.new(id: make_ref(), output_vector_length: 5)
		sensor = SensorProcess.start_link(sensor) 

		actuator = Actuator.new(id: make_ref())
		actuator = ActuatorProcess.start_link(actuator)
	
		# TODO: bug - after the sensor is connected to the neuron, the sensor process has an outdated
		# record for the sensor, sans connections info.
		# Fix idea #1 - send a message to the sensor telling it to form a connection to
    # the neuron, and ditto for the neuron.  that way it can update its internal state.
		{sensor, neuron} = Connector.connect_weighted(sensor, neuron, weight([20]))  
		IO.puts "sensor should be connected: #{inspect(sensor)}"
		{_neuron, actuator} = Connector.connect(neuron, actuator)

		SensorProcess.sync(sensor)
		timeout_milliseconds = 500
		received = ActuatorProcess.get_output(actuator, timeout_milliseconds)
		assert(received == 30)

	end

	def summation(inputs, weights, bias) do
		TestHelper.summation(inputs, weights, bias)
	end


	def receive_actuator_output() do
		:timeout
	end

	def weight(x) do
		x
	end

	def bias(x) do
		x
	end

end