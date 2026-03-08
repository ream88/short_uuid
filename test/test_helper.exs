ExUnit.start()

defmodule ShortUUID.Generators do
  @moduledoc false

  @abc Enum.concat([?0..?9, ?a..?f])

  def uuid do
    StreamData.map(
      StreamData.fixed_list([
        StreamData.string(@abc, length: 8),
        StreamData.constant("-"),
        StreamData.string(@abc, length: 4),
        StreamData.constant("-"),
        StreamData.string(@abc, length: 4),
        StreamData.constant("-"),
        StreamData.string(@abc, length: 4),
        StreamData.constant("-"),
        StreamData.string(@abc, length: 12)
      ]),
      &Enum.join/1
    )
  end
end
