#############################################################################
##
##  MAGMA_PIR.gd              RingsForHomalg package         Mohamed Barakat
##
##  Copyright 2008 Lehrstuhl B für Mathematik, RWTH Aachen
##
##  Implementations for commutative principal ideal rings in MAGMA.
##
#############################################################################

####################################
#
# constructor functions and methods:
#
####################################

InstallMethod( CreateHomalgTable,
        "for the ring of integers in MAGMA",
        [ IsHomalgExternalObjectRep
          and IsHomalgExternalObjectWithIOStream
          and IsPIRForHomalgInMAGMA ],
        
  function( arg )
    local RP, RP_BestBasis, RP_specific, component;
    
    RP := ShallowCopy( CommonHomalgTableForMAGMATools );
    
    RP_BestBasis := ShallowCopy( CommonHomalgTableForMAGMABestBasis );
    
    RP_specific :=
          rec(
               ## Can optionally be provided by the RingPackage
               ## (homalg functions check if these functions are defined or not)
               ## (HomalgTable gives no default value)
               
               RingName := "K[x]",
               
               ElementaryDivisors :=
                 function( M )
                   
                   return HomalgSendBlocking( [ "ElementaryDivisors(", M, ")" ], "need_output" );
                   
                 end,
                 
               ## Must be defined if other functions are not defined
               
               TriangularBasisOfRows :=
                 function( arg )
                   local M, R, nargs, N, U, rank_of_N;
                   
                   M := arg[1];
                   
                   R := HomalgRing( M );
                   
                   nargs := Length( arg );
                   
                   N := HomalgMatrix( "void", NrRows( M ), NrColumns( M ), R );
                   
                   if HasIsDiagonalMatrix( M ) and IsDiagonalMatrix( M ) then
                       SetIsDiagonalMatrix( N, true );
                   else
                       SetIsUpperTriangularMatrix( N, true );
                   fi;
                   
                   if nargs > 1 and IsHomalgMatrix( arg[2] ) then ## not TriangularBasisOfRows( M, "" )
                       # assign U:
                       U := arg[2];
                       SetNrRows( U, NrRows( M ) );
                       SetNrColumns( U, NrRows( M ) );
                       SetIsInvertibleMatrix( U, true );
                       
                       ## compute N and U:
                       rank_of_N := Int( HomalgSendBlocking( [ N, U, " := HermiteForm(", M, "); Rank(", N, ")" ], "need_output" ) );
                   else
                       ## compute N only:
                       rank_of_N := Int( HomalgSendBlocking( [ N, " := HermiteForm(", M, "); Rank(", N, ")" ], "need_output" ) );
                   fi;
                   
                   SetRowRankOfMatrix( N, rank_of_N );
                   
                   return N;
                   
                 end
               
          );
    
    for component in NamesOfComponents( RP_BestBasis ) do
        RP.(component) := RP_BestBasis.(component);
    od;
    
    for component in NamesOfComponents( RP_specific ) do
        RP.(component) := RP_specific.(component);
    od;
    
    Objectify( HomalgTableType, RP );
    
    return RP;
    
end );