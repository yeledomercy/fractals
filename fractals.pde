// Julia sets for Yelev's fractalish 4th birthday (May 1st, 2019)

// A class for complex numbers, viewed as (x,y) where x is the real part and y is the imaginary part
// We just implement the addition and the multiplication, because that's all we need at this point

class Complex {
     double x; // real part
     double y; // imaginary part
     Complex(double _x, double _y) { // def constructor
         x = _x; y = _y;
     }
     Complex(Complex c) { // copy constructor
         this(c.x, c.y);
     }
     
     void add(Complex c) { // adds c to the current number
          x += c.x;
          y += c.y;
     }
     // multiplies the current number by c
     void mult(Complex c) {
         double new_x = x * c.x - y * c.y;
         double new_y = x * c.y + y * c.x;
         x = new_x;
         y = new_y;
     }
     
     double sq_modulus() { // returns the square of the modulus (i.e. |z|^2) (we're too lazy to compute sqrt)
         return x * x + y * y; 
     }
     
}

// processing doesn't have the min function for double, which is a little silly, so we write it here
double min(double a, double b) { return a <= b ? a : b; }

// So what do we want? We want a coloring of the plane, which will interprete each point
// of the plane as a complex number and will iterate the function z -> z^2 + c for n iterations
// and see how far we go

double zoom_factor = 1.0;
Complex center = new Complex(0, 0);

// the 2d array of the colors (stored as 24 bit integers)
int[][] colors;
// width/height of the color array [needs to be initialized with the screen size for better results]
// (this is done in the setup method (which is the equivalent of 'main' in C)
int w = 100; int h = 100;

// recomputes the Julia set (i.e. assigns the colors to the color 2d array)
// the Julia set is that of the iterations of the map z --> z^2 + c, where c is a constant
// computed using the mouse coordinates
void recomp_fractal() {
     // the additive constant
     Complex c = new Complex(3.0 * (double) (mouseX - w/2) / w, 3.0 * (double) (mouseY - h/2) / h);
     // just to re-initialize the colors
     colors = new int[w][h];
     // the radius we need to exit
     double radius = 30;
     
     // for each of the points of the plane, associate a complex number z
     for (int x = 0; x < w; x++) {
          for (int y = 0; y < h; y++) {
              
              double z_real = (x - w/2) / (zoom_factor * 400.0); 
              double z_imag = (y - h/2) / (zoom_factor * 400.0);
              Complex z = new Complex(z_real, z_imag);
              z.add(center);
              
              // the number of iterations needed for the iterate to exit the disk of radius 
              int min_exit_n = -1;
              for (int n = 0; n < 100; n++) {
                   z.mult(z); z.add(c);
             
                   if (z.sq_modulus() > radius * radius) { min_exit_n = n; break; }
              }
            
              // 
              colors[x][y] = color(min(min_exit_n, 255), min(min_exit_n * 10, 255), min(min_exit_n * 15, 255));

          }
     }
}


// the function which is called when the program starts
void setup() {
     fullScreen();    // sets the size of the window to be full screen
     // width and height are global variables defined by processing, containing the size of the window
     w = width;  h = height;
     recomp_fractal();
}

// called when the mouse is clicked
void mouseClicked() {
    recomp_fractal();
    // saves the fractal picture, with #### denoting the frame number
    saveFrame("fractal-####.png");
}

void keyPressed(KeyEvent kev) {
    if (keyCode == UP && kev.isShiftDown()) {
         zoom_factor /= 1.1; 
    }
    if (keyCode == DOWN && kev.isShiftDown()) {
         zoom_factor *= 1.1;
    }
    
    if (kev.isShiftDown()) {
           
        if (keyCode == LEFT) {
            center.x += 0.01;
        }
        if (keyCode == RIGHT) {
            center.x -= 0.01;   
        }
        if (keyCode == UP) {
             center.y += 0.01;   
        }
        if (keyCode == DOWN) {
             center.y -= 0.01;   
        }
    }
    recomp_fractal();
}


// this function is called periodically, we use it to draw
void draw() {
    loadPixels();
    for (int x = 0; x < w; x++) {
         for (int y = 0; y < h; y++) {
             
              // sets the pixel at location (x,y) to colors[x][y]
              pixels[y * w + x] = colors[x][y];   
         }
    }
    updatePixels();
}
