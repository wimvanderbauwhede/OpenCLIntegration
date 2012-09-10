package CTypes;
use Exporter 'import'; # gives you Exporter's import() method directly
@EXPORT_OK = qw(
 &uint8_t 
 &int8_t 
 &uint16_t 
 &int16_t 
 &uint32_t 
 &int32_t 
 &uint64_t 
 &int64_t 
 &float 
 &double 
 &char 
 &short 
 &int 
 &long 
 &unsigned 
        );
# .x: int/float (1|0)
# x. : signed/unsigned (1|0)
# xxxx : size
sub uint8_t () { return 1+(1<<4)}
sub int8_t () { return 1+(3<<4)}
sub uint16_t () { return 2+(1<<4)}
sub int16_t () { return 2+(3<<4)}
sub uint32_t () { return 4+(1<<4)}
sub int32_t () { return 4+(3<<4)}
sub uint64_t () { return 8+(1<<4)}
sub int64_t () { return 8+(3<<4)}
sub float () { return 4+(0<<4)}
sub double () { return 8+(0<<4)}

# Aliases
sub char () { int8_t }
sub short { int16_t }
sub int () { int32_t }
sub long (;$) { int64_t }
sub unsigned ($) {
    (my $code) = @_;
    return $code-32;
}
