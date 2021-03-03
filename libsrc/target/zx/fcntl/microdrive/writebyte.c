/*
 *	Write a byte sequentially to Microdrive
 *
 *	Stefano Bodrato - Feb. 2021
 *
 *
 *	Not user callable - internal LIB routine
 *
 *	Enter with de = filehandle
 *
 *	$Id: writebyte.c $
*/

#include <fcntl.h>
#include <string.h>

// "stdio.h" contains definition for EOF
#include <stdio.h>
#include <zxinterface1.h>

int writebyte(int fd, int byte)
{
	struct M_CHAN *if1_file;
	int 	if1_filestatus;

	
	if1_file = (void *) fd;

	// Was the Microdrive full?  (see below)
	if (if1_file->hdflag > 127)  return(-1);


	if ( (if1_file->position != 0L) && ((int) ((if1_file->position ) % 512L) == 0L) )
	{
		// If we're on the last record, we will need to append a new one
		if ((if1_file->recflg & 2) != 0) {
				
			// This will overwrite/finalize the current sector.
			if1_file->recflg &= 0xFD;    // Reset EOF bit
			if1_write_sector (if1_file->drive, if1_file->sector, if1_file);

			// Microdrive full ?
			// We alwayse reserve one sector to prevent the 'ERASE' crash bug
			if (if1_free_sectors(if1_file->drive)<1) {
				if1_file->hdflag |= 128;
				return(-1);
			}
			
			// Let's update the sector data to initialize the next one
			bzero (if1_file->data, 512);
			if1_file->reclen=0;
			if1_file->bytecount=0;
			if1_file->recnum++;
			if1_file->recflg |= 2;    // Set EOF bit
			/*
			   When accessing to the Microdrive at sector level, the 'record' field
			   is used to specify the sector number to be written.
			   Let's spot a free one and assign the fresh value to the current buffer.
			*/
			if1_file->record = if1_find_sector(if1_file->drive);
			if1_file->sector = if1_file->record;
				
		} else {
			
			// If we're not at the file tail (EOF), let's pick the next record
			if1_filestatus = if1_load_record(if1_file->drive, if1_file->name, ++if1_file->record, if1_file);

			// Now get the current position in LONG format for our C driver
			if1_file->position = (long) if1_file->record * 512L + (long) if1_file->reclen;
			
			// TODO: possible error recovery, e.g. appending a new blank record
		}
	}

	
	//if1_file->data[if1_file->bytecount] == byte;
	*((unsigned char *) (if1_file->data + ( (int)(if1_file->position) % 512L))) = byte;
	
	if1_file->reclen++;
	if1_file->bytecount++;

		//fputc_cons ('|');
		//fputc_cons ( *(unsigned char *) (if1_file->data + ( (int)(if1_file->position) % 512)) );
	
	if1_file->position++;

}
