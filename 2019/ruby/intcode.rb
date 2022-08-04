# frozen_string_literal: true

def get_value(program, parameter, pmode)
  case pmode
  when :position then program[parameter]
  when :immediate then parameter
  end
end

def set_value(program, parameter, mode, value)
  raise unless mode == :position

  program[parameter] = value
end

def get_parameter_modes(optcode, nparameters)
  modes = %i[position immediate]
  (optcode / 100).to_s.rjust(nparameters, '0').chars.reverse.map { |m| modes[m.to_i] }
end

def run_instruction1(program, pointer, input, outputs)
  nparameters = 3
  optcode, i, j, k = program[pointer..pointer + nparameters]
  pmode_i, pmode_j, pmode_k = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  set_value program, k, pmode_k, value_i + value_j

  run_instructions program, pointer + 1 + nparameters, input, outputs
end

def run_instruction2(program, pointer, input, outputs)
  nparameters = 3
  optcode, i, j, k = program[pointer..pointer + nparameters]
  pmode_i, pmode_j, pmode_k = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  set_value program, k, pmode_k, value_i * value_j

  run_instructions program, pointer + 1 + nparameters, input, outputs
end

def run_instruction3(program, pointer, input, outputs)
  nparameters = 1
  optcode, i = program[pointer..pointer + nparameters]
  pmode_i, = get_parameter_modes optcode, nparameters
  set_value program, i, pmode_i, input

  run_instructions program, pointer + 1 + nparameters, input, outputs
end

def run_instruction4(program, pointer, input, outputs)
  nparameters = 1
  optcode, i = program[pointer..pointer + nparameters]
  pmode_i, = get_parameter_modes optcode, nparameters
  output = get_value program, i, pmode_i

  run_instructions program, pointer + 1 + nparameters, input, outputs + [output]
end

def run_instruction5(program, pointer, input, outputs)
  nparameters = 2
  optcode, i, j = program[pointer..pointer + nparameters]
  pmode_i, pmode_j = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  pointer = value_i.zero? ? pointer + 1 + nparameters : value_j

  run_instructions program, pointer, input, outputs
end

def run_instruction6(program, pointer, input, outputs)
  nparameters = 2
  optcode, i, j = program[pointer..pointer + nparameters]
  pmode_i, pmode_j = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  pointer = value_i.zero? ? value_j : pointer + 1 + nparameters

  run_instructions program, pointer, input, outputs
end

def run_instruction7(program, pointer, input, outputs)
  nparameters = 3
  optcode, i, j, k = program[pointer..pointer + nparameters]
  pmode_i, pmode_j, pmode_k = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  set_value program, k, pmode_k, value_i < value_j ? 1 : 0

  run_instructions program, pointer + 1 + nparameters, input, outputs
end

def run_instruction8(program, pointer, input, outputs)
  nparameters = 3
  optcode, i, j, k = program[pointer..pointer + nparameters]
  pmode_i, pmode_j, pmode_k = get_parameter_modes optcode, nparameters
  value_i = get_value program, i, pmode_i
  value_j = get_value program, j, pmode_j
  set_value program, k, pmode_k, value_i == value_j ? 1 : 0

  run_instructions program, pointer + 1 + nparameters, input, outputs
end

def run_instruction99(_program, _pointer, _input, outputs)
  outputs
end

def run_instructions(program, pointer, input, outputs)
  instructions = { 1 => :run_instruction1, 2 => :run_instruction2, 3 => :run_instruction3, 4 => :run_instruction4,
                   5 => :run_instruction5, 6 => :run_instruction6, 7 => :run_instruction7, 8 => :run_instruction8,
                   99 => :run_instruction99 }
  optcode = program[pointer] % 100
  method(instructions[optcode]).call program, pointer, input, outputs
end
