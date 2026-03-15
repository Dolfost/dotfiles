int a(int) { return 0; }
int b(int) { return 0; }
int c(int) { return 0; }

int main(int argc, char** argv) {
	a(
			b(
				c(
					1
				 )
			 )
	 );
  return 0;
}
