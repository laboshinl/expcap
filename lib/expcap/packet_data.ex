defimpl String.Chars, for: ExPcap.PacketData do
  def to_string(data) do
    String.strip("""
      length:             #{data.data_len}
      raw data:           #{ExPcap.Binaries.to_string(data.data)}
    """)
  end
end

defmodule ExPcap.PacketData do

  defstruct data_len:   0,
            data:       <<>>

  @type t :: %ExPcap.PacketData{
    data_len: non_neg_integer,
    data: binary
  }

  def read_reversed(data, packet_header) do
    %ExPcap.PacketData{
      data_len: packet_header.incl_len,
      data:     data # |> ExPcap.Binaries.reverse_binary
    }
  end

  def read_forward(data, packet_header) do
    %ExPcap.PacketData{
      data_len: packet_header.incl_len,
      data:     data
    }
  end

  def from_file(f, global_header, packet_header) do
    data = IO.binread(f, packet_header.incl_len)
    if ExPcap.GlobalHeader.reverse_bytes?(global_header) do
      data |> read_reversed(packet_header)
    else
      data |> read_forward(packet_header)
    end
  end

end
