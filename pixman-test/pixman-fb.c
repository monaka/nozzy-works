#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/vt.h>
#include <linux/kd.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>

int main (int argc,char **argv)
{
	int tty0_fd,new_vt;
	int new_tty_fd,kb_mode;
	struct vt_stat vts;
	char fname[16];
	struct termios tty_attr;
	char tty_buf[10];
	int n_char;
	tty0_fd=open("/dev/tty0",O_WRONLY | O_CLOEXEC);
	if (tty0_fd < 0) {
		perror("uh? cant open /dev/tty0,abort");
		exit(1);
	}
	if ( ioctl(tty0_fd,VT_OPENQRY,&new_vt) <0 ) {
		perror("uh? cant query new vc,abort");
		exit(1);
	}
	if (new_vt <0) {
		fprintf(stderr,"no more new vc,abort");
		exit(1);
	}	
	close(tty0_fd);
	snprintf(fname,sizeof(fname),"/dev/tty%d",new_vt);
	new_tty_fd=open(fname, O_RDWR | O_NOCTTY | O_CLOEXEC);
	if (new_tty_fd <0) {
		perror("uh? cant open new vc ,abort");
		exit(1);
	}
	if (ioctl(new_tty_fd, VT_GETSTATE, &vts) ==0) {
		if (ioctl(new_tty_fd, VT_ACTIVATE, new_vt) <0) {
			perror("uh? cant active new vc ,abort");
			exit(1);
		}
		if (ioctl(new_tty_fd, VT_WAITACTIVE, new_vt) <0) {
			perror("uh? cant wait for activation of new vc ,abort");
			exit(1);
		}
	}
	printf("Now activate %s ...\n",fname);
	if (tcgetattr(new_tty_fd,&tty_attr) < 0 ) {
		perror("uh? cant get attribute of tty,abort");
		exit(1);
	}
	cfmakeraw(&tty_attr);
	tty_attr.c_oflag |= OPOST | OCRNL;
	if (tcsetattr(new_tty_fd,TCSANOW, &tty_attr) < 0 ) {
		perror("uh? cant set attribute of tty,abort");
		exit(1);
	}
	if (ioctl(new_tty_fd, KDSKBMODE,K_OFF)) {
		if (ioctl(new_tty_fd, KDSKBMODE, K_RAW)) {
			perror("uh? KBD is not set K_RAW,abort");
			exit(1);
		}
	}
	if (ioctl(new_tty_fd, KDSKBMODE,KD_GRAPHICS)) {
		perror("uh? KBD is not set KD_GRAPHICS,abort");
		exit(1);
	}
	while(1) {
		memset(&tty_buf[0],0,sizeof(tty_buf));
		n_char=read(new_tty_fd,&tty_buf[0], sizeof(tty_buf)-1);
		if (n_char <0) {
			perror("uh? failure to read from tty,abort");
			exit(1);
		} else if  (n_char == 0) {
			sleep(1); /* avoid busy loop */
		}
		printf("key=%s\n",&tty_buf[0]);
	}	
	close(new_tty_fd);	
	exit(0);
}

