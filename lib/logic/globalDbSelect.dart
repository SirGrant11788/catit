GlobalDbSelect _globalDbSelect;

class GlobalDbSelect {
   int dbNumber;

  int get dbNo{
   return dbNumber;
 }

   void set dbNo(int dbNum){
   dbNumber = dbNum;
 }
   GlobalDbSelect({this.dbNumber});
}